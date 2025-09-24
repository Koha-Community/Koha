#!/usr/bin/perl

# Copyright 2024 Rijksmuseum, Koha Development team
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

use Test::More tests => 2;
use Test::NoWarnings;

use C4::AuthoritiesMarc;
use Koha::Authorities;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'move_to_deleted' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );    # TODO UNIMARC?

    my $record = MARC::Record->new;
    $record->append_fields( MARC::Field->new( '100', '1', '2', a => 'Name' ) );
    my $type   = $builder->build( { source => 'AuthType', value => { auth_tag_to_report => '100' } } );
    my $authid = C4::AuthoritiesMarc::AddAuthority(
        $record, undef,
        $type->{authtypecode}
    );
    my $authority = Koha::Authorities->find($authid);

    # Trivial test to see if 'move' really copies..
    my $count = $schema->resultset('DeletedauthHeader')->count;
    my $rec   = $authority->move_to_deleted;
    is( $schema->resultset('DeletedauthHeader')->count, $count + 1, 'count one higher' );

    # Check leader position 05 in marcxml
    like( $rec->marcxml, qr/<leader>.{5}d/, 'Leader in marcxml checked' );

    $schema->storage->txn_rollback;
};
