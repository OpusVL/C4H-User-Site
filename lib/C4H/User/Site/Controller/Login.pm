package C4H::User::Site::Controller::Login;

use Moose;
use C4H::User::Site::HTML::FormHandler::Bootstrap3;
BEGIN {extends 'OpusVL::AppKitX::PasswordReset::Controller::PasswordReset';}

has '+render_login_form_stash_key' => (
    default => 'render_form'
);

has '+login_form_class' => (
    default => 'C4H::User::Site::HTML::FormHandler::Bootstrap3'
);

has user_email_field => (
    is => 'ro',
    isa => 'Str',
    default => 'username',
);

has user_name_field => (
    is => 'ro',
    isa => 'Str',
    default => 'full_name',
);


after 'login' => sub {
    my ($self, $c) = @_;
    $c->detach(qw/Controller::Root default/);
};

after 'reset_password' => sub {
    my ($self, $c) = @_;

    $self->reset_password_form
        ->field('username')
        ->label('Email Address');

    $c->detach(qw/Controller::Root default/);
};

after 'reset' => sub {
    my ($self, $c) = @_;

    $c->detach(qw/Controller::Root default/);
};


1;

