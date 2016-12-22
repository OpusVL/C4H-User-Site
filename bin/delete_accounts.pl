#!perl

use strict;
use warnings;
use v5.14;

use Getopt::Long;
use C4H::User::Site;

my $days = shift // 7;

my $schema = C4H::User::Site->new->model('Users');

my $people_rs = $schema->resultset('Person');

while (my $input = readline) {
    # Stop at first blank
    last if $input !~ /\S/;

    my ($id, $email) = split ' ', $input;
    my $person = $people_rs->find($id);
    say "Not deleting $id because email $email does not match."
        and next
        unless $email eq $person->email_address;

    $person->delete;
    say "Deleted $id [$email] (@{ $person->groups })";
}
