#!/usr/bin/perl

use Modern::Perl;

use Koha::Installer;
exit !Koha::Installer->needs_update;
