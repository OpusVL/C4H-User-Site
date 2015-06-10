package C4H::User::Site::Builder;

use Moose;
extends 'OpusVL::Website::Builder';

override _build_plugins => sub {
    my $plugins = super(); # Get what CatalystX::AppBuilder gives you

#    push @$plugins, '+OpusVL::AppKitX::CMS::Odoo::Unsubscribe';

    return $plugins;
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
