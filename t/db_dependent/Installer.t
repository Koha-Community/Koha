#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!
# Bug 11541

use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
        use_ok('C4::Installer');
}

ok ( my $installer = C4::Installer->new(), 'Testing NewInstaller' );
is ( ref $installer, 'C4::Installer', 'Testing class of object' );
is ( $installer->{'dbname'},   C4::Context->config("database"), 'Testing DbName' );
is ( $installer->{'dbms'},     C4::Context->config("db_scheme") ? C4::Context->config("db_scheme") : "mysql", 'Testing DbScheme' );
is ( $installer->{'hostname'}, C4::Context->config("hostname"), 'Testing Hostname' );
is ( $installer->{'port'},     C4::Context->config("port"), 'Testing Port' );
is ( $installer->{'user'},     C4::Context->config("user"), 'Testing User' );
is ( $installer->{'password'}, C4::Context->config("pass"), 'Testing Password' );
