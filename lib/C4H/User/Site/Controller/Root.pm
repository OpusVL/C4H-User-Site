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
            
            my $blogs = $site->pages->attribute_search({ 'blog_category' => { '!=' => undef } }); 

            if ($blogs->count > 0) {
                my %categories;
                for my $blog ($blogs->all) {
                    my $attr = $blog->attribute('blog_category');
                    if (defined $attr) {
                        if ($categories{"$attr"}) {
                            $categories{"$attr"} = $categories{"$attr"}+1;
                        }
                        else {
                            $categories{"$attr"} = 1;
                        }
                    }
                }

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
