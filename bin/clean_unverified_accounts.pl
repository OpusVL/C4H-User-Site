#!perl

use strict;
use warnings;
use v5.14;

use Getopt::Long;
my %options;

GetOptions(\%options, 'commit|c');

use C4H::User::Site;

my $days = shift // 7;

my $schema = C4H::User::Site->new->model('Users');

my $people_rs = $schema->resultset('Person')->search({
   created => { '<' => \"NOW() - INTERVAL '$days DAYS'" }
});

my %delete;
my %keep;

while (my $person = $people_rs->next) {
    if($person->is_verified) {
        $keep{$person->id} = $person;
    }
    else {
        $delete{$person->id} = $person;
    }
}

say "KEEPING:";
for my $person_id (keys %keep) {
    my $groups = $keep{$person_id}->groups;
    say $person_id, "\t\t\t", "@$groups";
}
say scalar keys %keep, " KEPT";

say "DELETING:";
for my $person_id (keys %delete) {
    my $groups = $delete{$person_id}->groups;
    say $person_id, "\t\t\t", "@$groups";

    $delete{$person_id}->delete if $options{commit};
}
say scalar keys %delete, " DELETED";
