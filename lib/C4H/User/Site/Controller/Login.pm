package C4H::User::Site::Controller::Login;

use Moose;
use C4H::User::Site::HTML::FormHandler::Bootstrap3;
BEGIN {extends 'CatalystX::SimpleLogin::Controller::Login';}

has '+render_login_form_stash_key' => (
    default => 'render_form'
);

has '+login_form_class' => (
    default => 'C4H::User::Site::HTML::FormHandler::Bootstrap3'
);

after 'login' => sub {
    my ($self, $c) = @_;
    $c->detach(qw/Controller::Root default/);
};

1;

