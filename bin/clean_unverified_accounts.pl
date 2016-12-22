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
my $keep_count = 0;

while (my $person = $people_rs->next) {
    if($person->is_verified) {
        $keep_count++;
    }
    else {
        $delete{$person->id} = $person;
    }
}


say "DELETE";
for my $person_id (keys %delete) {
    my $groups = $delete{$person_id}->groups;
    say $person_id,  "\t", $delete{$person_id}->email_address, "\t\t\t", "@$groups";
}
say "";
say $keep_count, " TO KEEP";
say scalar keys %delete, " TO DELETE";
