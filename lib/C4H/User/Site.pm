package C4H::User::Site;

use strict;
use warnings;
use C4H::User::Site::Builder;

our $VERSION = "0.18";

my $builder = C4H::User::Site::Builder->new(
    appname => __PACKAGE__,
    version => $VERSION,
);

$builder->bootstrap;

1;

=head1 NAME

C4H::User::Site - Front end site for the users.

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
