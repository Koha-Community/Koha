#!/usr/bin/perl

# Copyright 2015 Koha Development team
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 5;
use MARC::Field;
use MARC::File::XML;
use MARC::Record;
use Test::Deep;

use Koha::Authority;
use Koha::Authorities;
use Koha::Authority::MergeRequest;
use Koha::Authority::MergeRequests;
use Koha::Authority::Type;
use Koha::Authority::Types;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder               = t::lib::TestBuilder->new;
my $nb_of_authorities     = Koha::Authorities->search->count;
my $nb_of_authority_types = Koha::Authority::Types->search->count;
my $new_authority_type_1  = Koha::Authority::Type->new(
    {   authtypecode       => 'my_ac_1',
        authtypetext       => 'my authority type text 1',
        auth_tag_to_report => '100',
        summary            => 'my summary for authority 1',
    }
)->store;
my $new_authority_1 = Koha::Authority->new( { authtypecode => $new_authority_type_1->authtypecode, } )->store;
my $new_authority_2 = Koha::Authority->new( { authtypecode => $new_authority_type_1->authtypecode, } )->store;

is( Koha::Authority::Types->search->count, $nb_of_authority_types + 1, 'The authority type should have been added' );
is( Koha::Authorities->search->count,      $nb_of_authorities + 2,     'The 2 authorities should have been added' );

$new_authority_1->delete;
is( Koha::Authorities->search->count, $nb_of_authorities + 1, 'Delete should have deleted the authority' );

subtest 'New merge request, method oldmarc' => sub {
    plan tests => 4;

    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '100', '', '', a => 'a', b => 'b_findme' ),
        MARC::Field->new( '200', '', '', a => 'aa' ),
    );
    my $req = Koha::Authority::MergeRequest->new({
        authid => $new_authority_2->authid,
        reportxml => 'Should be discarded',
    });
    is( $req->reportxml, undef, 'Reportxml is undef without oldrecord' );

    $req = Koha::Authority::MergeRequest->new({
        authid => $new_authority_2->authid,
        oldrecord => $marc,
    });
    like( $req->reportxml, qr/b_findme/, 'Reportxml initialized' );

    # Check if oldmarc is a MARC::Record and has one field
    is( ref( $req->oldmarc ), 'MARC::Record', 'Check oldmarc method' );
    is( scalar $req->oldmarc->fields, 1, 'Contains one field' );
};

subtest 'Testing reporting_tag_xml in MergeRequests' => sub {
    plan tests => 2;

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '024', '', '', a => 'aaa' ),
        MARC::Field->new( '100', '', '', a => 'Best author' ),
        MARC::Field->new( '234', '', '', a => 'Just a field' ),
    );
    my $xml = Koha::Authority::MergeRequests->reporting_tag_xml({
        record => $record, tag => '110',
    });
    is( $xml, undef, 'Expected no result for wrong tag' );
    $xml = Koha::Authority::MergeRequests->reporting_tag_xml({
        record => $record, tag => '100',
    });
    my $newrecord = MARC::Record->new_from_xml(
        $xml, 'UTF-8',
        C4::Context->preference('marcflavour') eq 'UNIMARC' ?
        'UNIMARCAUTH' :
        'MARC21',
    ); # MARC format does not actually matter here
    cmp_deeply( $record->field('100')->subfields,
        $newrecord->field('100')->subfields,
        'Compare reporting tag in both records',
    );
};

$schema->storage->txn_rollback;
