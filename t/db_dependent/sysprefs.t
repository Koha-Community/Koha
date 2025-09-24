#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2012 BibLibre SARL
# Copyright (C) 2013 Equinox Software, Inc.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 10;
use C4::Context;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $URLLinkText    = C4::Context->preference('URLLinkText');
my $newURLLinkText = "newURLLinkText";

C4::Context->set_preference( 'URLLINKTEXT', $newURLLinkText );
is( C4::Context->preference('URLLinkText'), $newURLLinkText, 'The pref should have been set correctly' );

C4::Context->set_preference( 'URLLinkText', $URLLinkText );
is( C4::Context->preference('URLLINKTEXT'), $URLLinkText, 'A pref name should be case insensitive' );

$ENV{OVERRIDE_SYSPREF_URLLinkText} = 'this is an override';
C4::Context->clear_syspref_cache();
is(
    C4::Context->preference('URLLinkText'),
    'this is an override',
    'system preference value overridden from environment'
);

is( C4::Context->preference('IDoNotExist'), undef, 'Get a non-existent system preference should return undef' );

C4::Context->set_preference( 'IDoNotExist', 'NonExistent' );
is( C4::Context->preference('IDoNotExist'), 'NonExistent', 'Test creation of non-existent system preference' );

C4::Context->set_preference( 'testpreference', 'abc' );
C4::Context->delete_preference('testpreference');
is( C4::Context->preference('testpreference'), undef, 'deleting preferences' );

# Test delete_preference, check cache; we need an example here with MIXED case !
C4::Context->enable_syspref_cache;
C4::Context->set_preference( 'TestPreference', 'def' );
is( C4::Context->preference('testpreference'), 'def', 'lower case, got right value' );
C4::Context->delete_preference('TestPreference');
is( C4::Context->preference('TestPreference'), undef, 'mixed case, cache is cleared' );
is( C4::Context->preference('testpreference'), undef, 'lower case, cache is cleared' );
