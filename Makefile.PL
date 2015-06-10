#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'OpusVL-Company-Website';
all_from 'lib/OpusVL/Company/Website.pm';

requires 'OpusVL::Website';
requires 'OpusVL::AppKitX::CMS::Odoo::Unsubscribe';

catalyst;

install_script glob('script/*.pl');
auto_install;
resources (
    repository => {
        url => 'ssh://git/srv/git/OpusVL-Company-Website',
        type => 'git',
    },
);

WriteAll;
