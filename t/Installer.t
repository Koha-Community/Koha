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

my $self;
ok ( my $installer = C4::Installer->new(), 'Testing NewInstaller' );
ok ( my $class = {shift}, 'Testing Shift' );
ok ( $self->{'dbname'} = C4::Context->config("database"), 'Testing DbName' );
ok ( $self->{'dbms'} = C4::Context->config("db_scheme") ? C4::Context->config("db_scheme") : "mysql", 'Testing DbScheme' );
ok ( $self->{'hostname'} = C4::Context->config("hostname"), 'Testing Hostname' );
ok ( $self->{'port'} = C4::Context->config("port"), 'Testing Port' );
ok ( $self->{'user'} = C4::Context->config("user"), 'Testing User' );
ok ( $self->{'password'} = C4::Context->config("pass"), 'Testing Password' );
