use strict;
use warnings;

use C4H::User::Site;

my $app = C4H::User::Site->apply_default_middlewares(C4H::User::Site->psgi_app);
$app;

