package C4H::User::Site::Builder;

use Moose;
extends 'OpusVL::Website::Builder';

override _build_plugins => sub {
    my $plugins = super(); # Get what CatalystX::AppBuilder gives you

    push @$plugins, '+Code4Health::AppKitX::Users';

    return $plugins;
};

override _build_config => sub 
{
    my $self   = shift;
    my $config = super(); # Get what CatalystX::AppBuilder gives you

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
