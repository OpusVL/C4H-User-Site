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

    my ($id, $email) = split ' ', $input, 3;
    my $person = $people_rs->find({
        id => $id,
        email_address => $email
    });

    if ($person->delete) {
        say "Deleted $id [$email] (@{ $person->groups })";
    }
    else {
        say "Not deleting $id because $email did not match";
    }
}
