package C4H::User::Site::Controller::Root;

use Moose;                                                                                                                                                   
use namespace::autoclean;                                                                                                                                    
use Email::MIME;                                                                                                                                             
use Email::Sender::Simple qw(sendmail);
#extends 'OpusVL::Website::Controller::Root';

BEGIN                                                                                                                                                        
{                                                                                                                                                            
    extends 'OpusVL::AppKitX::CMSView::Controller::CMS::Root';                                                                                               
}                                                                                                                                                            
                                                                                                                                                             
__PACKAGE__->config                                                                                                                                          
(                                                                                                                                                            
    appkit_myclass => 'C4H::User::Site',                                                                                                                    
);

sub preprocess {
    my ($self, $c, $me) = @_;
    my $site = $me->site;
    
    if ($c->config->{apperta_site}) {
        # BLOGS
        
        if ($me->blog or ($me->parent and $me->parent->blog)) {
        
            # ARCHIVES
            if ($c->req->query_params->{archive}) {
                my $months = {
                    ''              => 0,
                    'January'       => 1,
                    'February'      => 2,
                    'March'         => 3,
                    'April'         => 4,
                    'May'           => 5,
                    'June'          => 6,
                    'July'          => 7,
                    'August'        => 8,
                    'September'     => 9,
                    'October'       => 10,
                    'November'      => 11,
                    'December'      => 12
                };
                
                my $arc = $c->req->query_params->{archive};
                my ($month, $year) = split ' ', $arc;
                my $start_date = DateTime->new(month => $months->{$month}, year => $year);
                my $end_date = $start_date->clone->add( months => 1 )->subtract( days => 1 );
                my $blogs = $site->pages->attribute_search({ 'blog_category' => { '!=' => undef } });
                my $dtf = $c->model('CMS::Page')->result_source->schema->storage->datetime_parser;
                my $archived = $site->pages->search({
                    'parent.blog' => 1,
                    'me.created' => {
                        -between => [
                            $dtf->format_datetime($start_date),
                            $dtf->format_datetime($end_date)
                        ]
                    },
                    'me.status' => 'published',
                },
                {
                    join => 'parent',
                    page => $c->req->query_params->{page} ? $c->req->query_params->{page} : 1,
                    rows => 3,
                    order_by => {'-asc' => "priority"}
                });

                $c->stash->{archived_date} = $arc;
                $c->stash->{archived} = $archived;
            }    

            my $blogs = $site->pages->attribute_search({ 'blog_category' => { '!=' => undef } }); 

            if ($blogs->count > 0) {
                my %categories;
                my $dates = {}; # DT => blog
                for my $blog ($blogs->all) {
                    my $attr = $blog->attribute('blog_category');
                    if (defined $attr) {
                        my ($month, $year) = ($blog->created->month_name, $blog->created->year);
                        my $date = "${month} ${year}";
                        if ($dates->{$date}) {
                            push @{$dates->{$date}}, $blog->id;
                        }
                        else {
                            $dates->{$date} = [];
                            push @{$dates->{$date}}, $blog->id;
                        }
                        if ($categories{"$attr"}) {
                            $categories{"$attr"} = $categories{"$attr"}+1;
                        }
                        else {
                            $categories{"$attr"} = 1;
                        }
                    }
                }

                $c->stash->{archives} = $dates;
                $c->stash->{categories} = \%categories; 
            }
        }

        # CONTACT FORM
        if ($c->req->body_params->{"submit-contact-form"}) {
            my ($site_id, $name, $email, $telephone, $comment) = (
                $c->req->body_params->{"site"},
                $c->req->body_params->{"name"},
                $c->req->body_params->{"email"},
                $c->req->body_params->{"telephone"},
                $c->req->body_params->{"comment"},
            );

            # only submit if required fields are there
            #if ($site_id) {
                if ($name and $email and $comment) {
                    $telephone = $telephone ? $telephone : 'Not set';
                    my $full_msg = "Name: ${name}\n";
                       $full_msg .= "Telephone: ${telephone}\n";
                       $full_msg .= "Email: ${email}\n";
                       $full_msg .= "Message: ${comment}\n";
                    my $msg = Email::MIME->create(
                        header_str => [
                            From    => $site->attribute('contact-mail-from'),
                            To      => $site->attribute('contact-form-mail-to'),
                            Subject => "Contact form feedback (" . $site->name . ")",
                        ],
                        attributes => {
                            encoding => 'quoted-printable',
                            charset  => 'ISO-8859-1',
                        },
                        body_str => $full_msg,
                    );

                    sendmail($msg);
                    $c->flash->{success_msg} = 1;
                    $c->res->redirect($c->req->uri);
                }
                else {
                    $c->flash->{error_msg} = "Please ensure all mandatory fields are filled out then resubmit";
                    $c->flash(
                        form_name        => $name||"",
                        form_telephone   => $telephone||"",
                        form_comment     => $comment||"",
                        form_email       => $email||"",
                    );
                    $c->res->redirect($c->req->uri);
                }
            #}
            #else {
            #    $c->flash->{error_msg} = "An error has occurred. Please try again later";
            #    $c->res->redirect($c->req->uri);
            #}
        }   
    }
}

sub searchQuery
    : Path('/searchQuery')
    : Args(0)
    : Public
{
    my ($self, $c) = @_;
    if ($c->req->query_params->{q} and $c->req->query_params->{sid}) {
        my $query = $c->req->query_params->{q};
        my $sid   = $c->req->query_params->{sid};
        my $results = $c->model('CMS::Page')->search({
            site    => $sid,
            status  => 'published',
            -or     => [
                description => { 'ilike', "%$query%" },
                title       => { 'ilike', "%$query%" },
                h1          => { 'ilike', "%$query%" },
            ],
        });

        if ($results->count > 0) {
            $c->stash->{search_results} = [ $results->all ];
        }
    }

    $c->detach(qw/Controller::Root default/);
}

1;
