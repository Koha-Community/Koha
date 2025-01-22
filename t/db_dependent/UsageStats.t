# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use t::lib::Mocks qw(mock_preference);
use t::lib::TestBuilder;

use POSIX qw(strftime);

use C4::Reserves qw(AddReserve);
use Koha::Authorities;
use Koha::Biblios;
use Koha::Items;
use Koha::Libraries;
use Koha::Old::Checkouts;
use Koha::Old::Holds;
use Koha::Patrons;

BEGIN {
    use_ok( 'C4::UsageStats', qw( BuildReport ReportToCommunity _count ) );
}

can_ok(
    'C4::UsageStats', qw(
        BuildReport
        ReportToCommunity
        _count )
);

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'BuildReport() tests' => sub {

    plan tests => 30;

    $schema->storage->txn_begin;

    # make sure we have some data for each 'volumetry' key
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $biblio   = $builder->build_sample_biblio();
    my $item     = $builder->build_sample_item();
    $builder->build_object( { class => 'Koha::Old::Holds' } );
    $builder->build_object( { class => 'Koha::Old::Checkouts' } );

    t::lib::Mocks::mock_preference( "UsageStatsID",            0 );
    t::lib::Mocks::mock_preference( "UsageStatsLibraryName",   0 );
    t::lib::Mocks::mock_preference( "UsageStatsLibrariesInfo", 0 );
    t::lib::Mocks::mock_preference( "UsageStatsLibraryType",   0 );
    t::lib::Mocks::mock_preference( "UsageStatsCountry",       0 );
    t::lib::Mocks::mock_preference( "UsageStatsLibraryUrl",    0 );

    my $report = C4::UsageStats->BuildReport();

    isa_ok( $report,              'HASH',  '$report is a HASH' );
    isa_ok( $report->{libraries}, 'ARRAY', '$report->{libraries} is an ARRAY' );
    is( scalar( @{ $report->{libraries} } ),    0,  "There are 0 fields in libraries, libraries info are not shared" );
    is( $report->{installation}->{koha_id},     0,  "UsageStatsID          is good" );
    is( $report->{installation}->{name},        '', "UsageStatsLibraryName is good" );
    is( $report->{installation}->{url},         '', "UsageStatsLibraryUrl  is good" );
    is( $report->{installation}->{type},        '', "UsageStatsLibraryType is good" );
    is( $report->{installation}->{country},     '', "UsageStatsCountry     is good" );
    is( $report->{installation}->{geolocation}, '', "UsageStatsGeolocation is good" );

    #mock with values
    t::lib::Mocks::mock_preference( "UsageStatsID",            1 );
    t::lib::Mocks::mock_preference( "UsageStatsLibraryName",   'NAME' );
    t::lib::Mocks::mock_preference( "UsageStatsLibraryUrl",    'URL' );
    t::lib::Mocks::mock_preference( "UsageStatsLibraryType",   'TYPE' );
    t::lib::Mocks::mock_preference( "UsageStatsCountry",       'COUNTRY' );
    t::lib::Mocks::mock_preference( "UsageStatsLibrariesInfo", 1 );
    t::lib::Mocks::mock_preference( "UsageStatsGeolocation",   1 );

    $report = C4::UsageStats->BuildReport();

    isa_ok( $report,              'HASH',  '$report is a HASH' );
    isa_ok( $report->{libraries}, 'ARRAY', '$report->{libraries} is an ARRAY' );
    is( scalar( @{ $report->{libraries} } ),    Koha::Libraries->count, "There are 6 fields in $report->{libraries}" );
    is( $report->{installation}->{koha_id},     1,                      "UsageStatsID          is good" );
    is( $report->{installation}->{name},        'NAME',                 "UsageStatsLibraryName is good" );
    is( $report->{installation}->{url},         'URL',                  "UsageStatsLibraryUrl  is good" );
    is( $report->{installation}->{type},        'TYPE',                 "UsageStatsLibraryType is good" );
    is( $report->{installation}->{country},     'COUNTRY',              "UsageStatsCountry is good" );
    is( $report->{installation}->{geolocation}, '1',                    "UsageStatsGeolocation is good" );
    ok( exists $report->{systempreferences}, 'systempreferences is present' );

    isa_ok( $report,              'HASH', '$report is a HASH' );
    isa_ok( $report->{volumetry}, 'HASH', '$report->{volumetry} is a HASH' );
    is( scalar( keys %{ $report->{volumetry} } ), 8,                           "There are 8 fields in 'volumetry'" );
    is( $report->{volumetry}->{biblio},           Koha::Biblios->count,        "Biblios count correct" );
    is( $report->{volumetry}->{items},            Koha::Items->count,          "Items count correct" );
    is( $report->{volumetry}->{auth_header},      Koha::Authorities->count,    "Authorities count correct" );
    is( $report->{volumetry}->{old_issues},       Koha::Old::Checkouts->count, "Old checkouts count correct" );
    is( $report->{volumetry}->{old_reserves},     Koha::Old::Holds->count,     "Old holds count correct" );
    is( $report->{volumetry}->{borrowers},        Koha::Patrons->count,        "Patrons count correct" );
    is( $report->{volumetry}->{aqorders},         Koha::Acquisition::Orders->count, "Orders count correct" );
    is( $report->{volumetry}->{subscription},     Koha::Subscriptions->count,       "Suscriptions count correct" );

    $schema->storage->txn_rollback;
};
