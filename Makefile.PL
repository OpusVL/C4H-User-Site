#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'C4H-User-Site';
all_from 'lib/C4H/User/Site.pm';

requires 'OpusVL::Website' => 0.08;
requires 'Code4Health::AppKitX::Users';

catalyst;

install_script glob('script/*.pl');
auto_install;
resources (
    repository => {
        url => 'ssh://git/srv/git/C4H-User-Site',
        type => 'git',
    },
);

WriteAll;
