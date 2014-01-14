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
ok ( my $class = {shift}, 'Testing Shift' );
ok ( my $self->{'dbname'} = C4::Context->config("database"), 'Testing DbName' );
ok ( my $self->{'dbms'} = C4::Context->config("db_scheme") ? C4::Context->config("db_scheme") : "mysql", 'Testing DbScheme' );
ok ( my $self->{'hostname'} = C4::Context->config("hostname"), 'Testing Hostname' );
ok ( my	$self->{'port'} = C4::Context->config("port"), 'Testing Port' );
ok ( my	$self->{'user'} = C4::Context->config("user"), 'Testing User' );
ok ( my $self->{'password'} = C4::Context->config("pass"), 'Testing Password' );
