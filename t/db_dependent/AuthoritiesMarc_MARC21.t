#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::MockModule;
use Test::MockObject;
use Test::More tests => 5;
use t::lib::Mocks;
use MARC::Record;

use C4::AuthoritiesMarc qw( FindDuplicateAuthority );

BEGIN {
        use_ok('C4::AuthoritiesMarc::MARC21', qw( default_auth_type_location fix_marc21_auth_type_location ));
}

my @result = C4::AuthoritiesMarc::MARC21::default_auth_type_location();
ok($result[0] eq '942', "testing default_auth_type_location has first value '942'");
ok($result[1] eq 'a', "testing default_auth_type_location has first value 'a'");

my $marc_record = MARC::Record->new();
is(C4::AuthoritiesMarc::MARC21::fix_marc21_auth_type_location($marc_record, '', ''), undef, "testing fix_marc21_auth_type_location returns undef with empty MARC record");

subtest "FindDuplicateAuthority tests" => sub {
    plan tests => 2;
    my $zebra_search_module = Test::MockModule->new( 'C4::Search' );
    $zebra_search_module->mock( 'SimpleSearch', sub {
        my $query = shift;
        return ( undef, [$query] );
    });
    $zebra_search_module->mock( 'new_record_from_zebra', sub {
        my (undef, $query ) = @_;
        my $marc = MARC::Record->new;
        $marc->append_fields(
            MARC::Field->new( '001', $query ),
        );
        return $marc;
    });
    my $es_search_module = Test::MockModule->new( 'Koha::SearchEngine::Elasticsearch::Search' );
    $es_search_module->mock( 'simple_search_compat', sub {
        my (undef, $query) = @_;
        return ( undef, [$query] );
    });

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new('155', '', '', a => 'Potato' ),
    );

    t::lib::Mocks::mock_preference( 'SearchEngine', 'Zebra' );
    my ($query) = FindDuplicateAuthority( $record, "GENRE/FORM" );
    is( $query, q{at:"GENRE/FORM"  AND he:"Potato"}, "Query formed correctly for Zebra");

    t::lib::Mocks::mock_preference( 'SearchEngine', 'Elasticsearch' );
    ($query) = FindDuplicateAuthority( $record, "GENRE/FORM" );
    is( $query, q{at:"GENRE/FORM"  AND he:"Potato"}, "Query formed correctly for Elasticsearch");

};
