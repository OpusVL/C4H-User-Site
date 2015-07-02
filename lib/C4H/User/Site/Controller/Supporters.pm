package C4H::User::Site::Controller::Supporters;

use Moose;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Code4Health::DB::Form::Supporters::Apply;

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
    my $form = Code4Health::DB::Form::Supporters::Apply->new;
    $c->stash(form => $form);
    $form->process($c->req->params);

    if ($form->validated) {
        my @fields = map { $_ unless $_ eq 'submit' } sort keys %{$c->req->body_params};
        my $full_msg = "A new user would like to apply as a supporter!\n\n";
        for my $field (@fields) {
            $full_msg .= "${field}: " . $c->req->body_params->{$field} . "\n";
        }
        my $msg = Email::MIME->create(
            header_str => [
                From    => 'supporters.code4health@nhs.net',
                To      => $c->config->{mailto_address}, 
                Subject => "Apply as a supporter",
            ],
            attributes => {
                encoding => 'quoted-printable',
                charset  => 'ISO-8859-1',
            },
            body_str => $full_msg,
        );

        sendmail($msg);
        $c->flash->{success_msg} = "Thank You. Your response was sent";
        $c->res->redirect($c->req->uri);
    }

    $c->stash->{render_form} = $form->render;
    $c->detach(qw/Controller::Root default/);
}

1;
__END__
