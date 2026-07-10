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

use Test::MockModule;
use Test::More tests => 3;
use Test::NoWarnings;

use C4::AuthoritiesMarc;
use Koha::Authorities;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'move_to_deleted' => sub {
    plan tests => 6;
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

    $record = MARC::Record->new;
    $record->append_fields( MARC::Field->new( '100', '1', '2', a => 'Name' ) );
    $record->append_fields( MARC::Field->new( '040', '',  '',  c => 'Test' ) );
    $type   = $builder->build( { source => 'AuthType', value => { auth_tag_to_report => '100' } } );
    $authid = C4::AuthoritiesMarc::AddAuthority(
        $record, undef,
        $type->{authtypecode}
    );
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        q|UPDATE auth_header  SET marcxml = UpdateXML(marcxml, '//datafield[@tag="040"]/subfield[@code="c"]',CONCAT('<subfield code',CHAR(27),'="c">OSt</subfield>')) WHERE auth_header.authid=?|
    );
    $sth->execute( ($authid) );
    $authority = Koha::Authorities->find($authid);
    $count     = $schema->resultset('DeletedauthHeader')->count;
    $rec       = $authority->move_to_deleted;
    is(
        $schema->resultset('DeletedauthHeader')->count, $count + 1,
        'count one higher, successfully deleted record with invalid XML characters'
    );

    # Check leader position 05 in marcxml
    like( $rec->marcxml, qr/<leader>.{5}d/, 'Leader in marcxml checked, error was recoverable so leader updated' );

    my $ka = Test::MockModule->new('Koha::Authority');
    $ka->mock(
        'record_strip_nonxml',
        sub {
            return;
        }
    );
    $record = MARC::Record->new;
    $record->append_fields( MARC::Field->new( '100', '1', '2', a => 'Name' ) );
    $record->append_fields( MARC::Field->new( '040', '',  '',  c => 'Test' ) );
    $type   = $builder->build( { source => 'AuthType', value => { auth_tag_to_report => '100' } } );
    $authid = C4::AuthoritiesMarc::AddAuthority(
        $record, undef,
        $type->{authtypecode}
    );
    $dbh = C4::Context->dbh;
    $sth = $dbh->prepare(
        q|UPDATE auth_header  SET marcxml = UpdateXML(marcxml, '//datafield[@tag="040"]/subfield[@code="c"]',CONCAT('<subfield code',CHAR(27),'="c">OSt</subfield>')) WHERE auth_header.authid=?|
    );
    $sth->execute( ($authid) );
    $authority = Koha::Authorities->find($authid);
    $count     = $schema->resultset('DeletedauthHeader')->count;
    $rec       = $authority->move_to_deleted;
    is(
        $schema->resultset('DeletedauthHeader')->count, $count + 1,
        'count one higher, successfully deleted record with invalid XML characters'
    );

    # Check leader position 05 in marcxml
    unlike(
        $rec->marcxml, qr/<leader>.{5}d/,
        'Leader in marcxml checked, error was unrecoverable so leader not updated'
    );

    $schema->storage->txn_rollback;
};

subtest 'default_marc21_008 tests (bug 31925)' => sub {
    plan tests => 7;

    is(
        substr( Koha::Authority->default_marc21_008('lcsh'), 5, 1 ), 'a',
        'lcsh maps to 008/11 code a'
    );
    is(
        substr( Koha::Authority->default_marc21_008('mesh'), 5, 1 ), 'c',
        'mesh maps to 008/11 code c'
    );
    is(
        substr( Koha::Authority->default_marc21_008('rvm'), 5, 1 ), 'v',
        'rvm maps to 008/11 code v'
    );
    is(
        substr( Koha::Authority->default_marc21_008('fast'), 5, 1 ), 'z',
        'Unrecognized raw $2 code (e.g. fast, from an ind2=7 heading) maps to 008/11 code z (Other)'
    );

    t::lib::Mocks::mock_preference( 'MARCAuthorityControlField008', '' );
    is(
        Koha::Authority->default_marc21_008, '|| aca||aabn           | a|a     d',
        'Falls back to the hardcoded default when the syspref is unset, and thesaurus is not passed'
    );
    is(
        substr( Koha::Authority->default_marc21_008('fast'), 5, 1 ), 'z',
        'Thesaurus code is still applied on top of the hardcoded default'
    );

    my $custom = '||caaa||aabn           | a|a     d##padding';
    t::lib::Mocks::mock_preference( 'MARCAuthorityControlField008', $custom );
    is(
        Koha::Authority->default_marc21_008, substr( $custom, 0, 34 ),
        'Uses the syspref value, truncated to 34 characters, when valid'
    );
};
