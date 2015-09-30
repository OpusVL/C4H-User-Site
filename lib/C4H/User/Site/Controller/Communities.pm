package C4H::User::Site::Controller::Communities;

use Moose;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Code4Health::DB::Form::Communities::Apply;

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
        my $msg = Email::MIME->create(
            header_str => [
                From    => 'communities.code4health@nhs.net',
                To      => $c->config->{mailto_address}, 
                Subject => "Apply for community",
            ],
            attributes => {
                encoding => 'quoted-printable',
                charset  => 'ISO-8859-1',
            },
            body_str => $full_msg,
        );

        sendmail($msg);
        $c->flash->{success_msg} = "Thank you. Your application has been forwarded to one of our team who will be in touch shortly";

        $c->stash->{email} = {
            to => $c->config->{mailto_address},
            from => $c->config->{system_email_address},
            subject => "New Code4Health community application",
            body => $full_msg,
        };
        $c->forward($c->view('Email'));

        $c->res->redirect($c->req->uri);
    }

    $c->stash->{render_form} = $form->render;
    $c->detach(qw/Controller::Root default/);
}

1;
__END__
