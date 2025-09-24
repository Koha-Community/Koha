#!/usr/bin/perl

# Copyright 2017 Koha Development team
#
# This file is part of Koha
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
use Test::More tests => 2;

use t::lib::TestBuilder;

use Koha::Authority::Tags;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest "Some supertrivial tests for Tag" => sub {
    plan tests => 3;
    my $authtype = t::lib::TestBuilder->new->build( { source => 'AuthType' } );
    my $cnt      = Koha::Authority::Tags->count;
    my $rec      = Koha::Authority::Tag->new(
        {
            authtypecode => $authtype->{authtypecode},
            tagfield     => '100',
        }
    )->store;
    is( Koha::Authority::Tags->count, $cnt + 1, 'One record added' );
    $rec->update( { liblibrarian => 'another intelligent idea' } );
    is(
        Koha::Authority::Tags->find( $authtype->{authtypecode}, '100' )->liblibrarian, 'another intelligent idea',
        'Found record'
    );
    $rec->delete;
    is( Koha::Authority::Tags->count, $cnt, 'One record deleted' );
};

$schema->storage->txn_rollback;
