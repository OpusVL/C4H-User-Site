package C4H::User::Site::Controller::Communities;

use Moose;

use Text::Markdown 'markdown';
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Code4Health::DB::Form::Communities::Apply;
use Code4Health::DB::Form::Communities::PostUpdate;
use Template::Alloy;

BEGIN {
    extends 'Catalyst::Controller::HTML::FormFu';
    with 'OpusVL::AppKit::RolesFor::Controller::GUI';
}

sub apply_for_community
    :Path('apply')
    :Public
    :Args(0)
{
    my ($self, $c) = @_;
    my $form = Code4Health::DB::Form::Communities::Apply->new;
    $c->stash(form => $form);
    $form->process($c->req->params);

    if ($form->validated) {
        my @fields = map { $_ unless $_ eq 'submit' } sort keys %{$c->req->body_params};
        my $full_msg = "A new user would like to apply for a community!\n\n";
        for my $field (@fields) {
            $full_msg .= "${field}: " . $c->req->body_params->{$field} . "\n";
        }

        $c->flash->{success_msg} = "Thank you. Your application has been forwarded to one of our team who will be in touch shortly";

        $c->stash->{email} = {
            to => $c->config->{mailto_address},
            from => $c->config->{system_email_address},
            subject => "New Code4Health community application",
            body => $full_msg,
        };
        $c->forward($c->view('Email'));

        # Now send a reference email to the Customer
        # Required params: signup.community.email and signup.community.subject
        my $subject = $c->model('SysParams::SysInfo')->get('signup.community.subject');
        my $message = $c->model('SysParams::SysInfo')->get('signup.community.email');
        
        if ($subject and $message) {
            my $out_msg = '';
            my $t       = Template::Alloy->new;
            $t->process(\$message, $c->req->body_params, \$out_msg);
            $c->stash->{email} = {
                to      => $form->field('email_address')->value,
                from    => $c->config->{system_email_address},
                subject => $subject,
                body    => $out_msg,
            };

            $c->forward($c->view('Email'));
        }

        $c->res->redirect($c->req->uri);
    }

    $c->stash->{render_form} = $form->render;
    $c->detach(qw/Controller::Root default/);
}

sub post_update
    :Public
    :Path('post-update')
    :Args(0)
    :Does('NeedsLogin')
{
    my ($self, $c) = @_;
    my $root_controller = $c->controller('Root');
    my $site = $root_controller->_get_site($c);
    my $community_code = $c->req->query_params->{community_code};

    $c->log->debug($c->user->prf_get('community_admin'));
    unless ($c->user->prf_get('community_admin')) {
        $c->detach('/not_found');
    }
    unless ($c->user->member_of_community($community_code)) {
        $c->detach('/not_found');
    }

    my ($com_page) = $site->pages->attribute_search($site->id, {
        community_code => $community_code
    } );

    unless ($com_page) {
        # Somehow became a member of a community with no page?
        $c->log->debug("No page was found for community $community_code");
        $c->detach('/not_found');
    }

    my $form = Code4Health::DB::Form::Communities::PostUpdate->new;
    $form->process($c->req->params);

    if ($form->validated) {
        my $url = $form->field('title')->value =~ s/[^a-z0-9_]+/-/gri;
        $url = $com_page->url . '/' . $url;
        $url = lc $url;

        my $page = $c->model('CMS::Page')->create({
            url         => $url,
            description => $form->field('title')->value,
            title       => $form->field('title')->value,
            h1          => $form->field('title')->value,
            breadcrumb  => $form->field('title')->value,
            parent_id   => $com_page->id,
            markup_type => 'Markdown',
            site        => $site->id,
            status      => 'published',
            blog        => 0,
            content_type => 'text/html',
        });

        my $content = $form->field('update')->value;
        $page->set_content($content);
        my $attr = $site->page_attribute_details->find({ code => 'future_plans' });
        $page->create_related('attribute_values', {
            value => markdown( $form->field('future_plans')->value ),
            field_id => $attr->id,
        });

        $attr = $site->page_attribute_details->find({ code => 'community_help' });

        $page->create_related('attribute_values', {
            value => markdown( $form->field('help')->value ),
            field_id => $attr->id,
        });
        $c->res->redirect($com_page->url);
    }

    $c->stash->{render_form} = $form->render;
    $c->detach(qw/Controller::Root default/);
}
1;
__END__
