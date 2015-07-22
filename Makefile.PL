#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'C4H-User-Site';
all_from 'lib/C4H/User/Site.pm';

requires 'OpusVL::Website' => "0.08";
requires 'OpusVL::AppKitX::PasswordReset' => "0.03";
requires 'Code4Health::AppKitX::Users' => "0.04";
requires 'Code4Health::DB' => "0.05";
requires 'Code4Health::LDAP' => "0.04";
requires 'Email::MIME' => "1.929";
requires 'Email::Sender::Simple' => "1.300018";
requires 'Template::Plugin::JSON' => "0.06";

test_requires 'OpusVL::AppKitX::PreferencesAdmin' => "0.02";

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
