package C4H::User::Site::Builder;

use Moose;
use File::ShareDir;
extends 'OpusVL::Website::Builder';

override _build_plugins => sub {
    my $plugins = super(); # Get what OpusVL::Website::Builder gives you

    push @$plugins, qw/
        +Code4Health::AppKitX::Users
        +OpusVL::AppKitX::SysParams
    /;

    return $plugins;
};

override _build_config => sub 
{
    my $self   = shift;
    my $config = super(); # Get what OpusVL::Website::Builder gives you

    $config->{no_formfu_classes} = 1;

    $config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path} = [];
    $config->{'Controller::HTML::FormFu'}->{constructor}->{render_method} = 'tt';
    $config->{'Controller::HTML::FormFu'}->{constructor}->{tt_args} = {
        INCLUDE_PATH => File::ShareDir::module_dir('C4H::User::Site').'/root/formfu'
    };

    $config->{'Controller::Login'} =
    {
        traits => '+OpusVL::AppKit::TraitFor::Controller::Login::NewSessionIdOnLogin',
    };

    $config->{'Plugin::Authentication'} =
    {
            default_realm   => 'ldap',
            ldap          =>
            {
                credential =>
                {
                   class              => 'Password',
                   password_type      => 'self_check',
                },
                store =>
                {
                   class              => 'DBIx::Class',
                   user_model         => 'Users::Person',
                }
            },
    };

    $config->{'View::CMS::Page'}->{AUTO_FILTER} = 'html';

    return $config;
};

1;

=head1 NAME

C4H::User::Site::Builder

=head1 DESCRIPTION



=head1 METHODS

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
