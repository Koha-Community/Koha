#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 15;

use t::lib::TestBuilder;

use Koha::Database;
use C4::Context;
use Koha::AuthorisedValue;
use Koha::AuthorisedValues;
use Koha::AuthorisedValueCategories;
use Koha::MarcSubfieldStructures;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

Koha::AuthorisedValues->delete;
Koha::AuthorisedValueCategories->delete;

# insert
Koha::AuthorisedValueCategory->new({ category_name => 'av_for_testing' })->store;
Koha::AuthorisedValueCategory->new({ category_name => 'aaav_for_testing' })->store;
Koha::AuthorisedValueCategory->new({ category_name => 'restricted_for_testing' })->store;
my $av1 = Koha::AuthorisedValue->new(
    {
        category         => 'av_for_testing',
        authorised_value => 'value 1',
        lib              => 'display value 1',
        lib_opac         => 'opac display value 1',
        imageurl         => 'image1.png',
    }
)->store();

my $av2 = Koha::AuthorisedValue->new(
    {
        category         => 'av_for_testing',
        authorised_value => 'value 2',
        lib              => 'display value 2',
        lib_opac         => 'opac display value 2',
        imageurl         => 'image2.png',
    }
)->store();

my $av3 = Koha::AuthorisedValue->new(
    {
        category         => 'av_for_testing',
        authorised_value => 'value 3',
        lib              => 'display value 3',
        lib_opac         => 'opac display value 3',
        imageurl         => 'image2.png',
    }
)->store();

my $av4 = Koha::AuthorisedValue->new(
    {
        category         => 'aaav_for_testing',
        authorised_value => 'value 4',
        lib              => 'display value 4',
        lib_opac         => 'opac display value 4',
        imageurl         => 'image4.png',
    }
)->store();
my $av_empty_string = Koha::AuthorisedValue->new(
    {
        category         => 'restricted_for_testing',
        authorised_value => undef, # Should have been defaulted to ""
        lib              => 'display value undef',
        lib_opac         => 'opac display value undef',
    }
)->store();
my $av_0 = Koha::AuthorisedValue->new(
    {
        category         => 'restricted_for_testing',
        authorised_value => 0,
        lib              => 'display value 0',
        lib_opac         => 'opac display value 0',
    }
)->store();

ok( $av1->id(), 'AV 1 is inserted' );
ok( $av2->id(), 'AV 2 is inserted' );
ok( $av3->id(), 'AV 3 is inserted' );
ok( $av4->id(), 'AV 4 is inserted' );

is( $av3->opac_description, 'opac display value 3', 'Got correction opac description if lib_opac is set' );
$av3->lib_opac('');
is( $av3->opac_description, 'display value 3', 'Got correction opac description if lib_opac is *not* set' );

my @authorised_values =
  Koha::AuthorisedValues->new()->search( { category => 'av_for_testing' } );
is( @authorised_values, 3, "Get correct number of values" );

my $branchcode1 = $builder->build({ source => 'Branch' })->{branchcode};
my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};

$av1->add_branch_limitation( $branchcode1 );

@authorised_values = Koha::AuthorisedValues->new()->search( { category => 'av_for_testing', branchcode => $branchcode1 } );
is( @authorised_values, 3, "Search including value with a branch limit ( branch can use the limited value ) gives correct number of results" );

@authorised_values = Koha::AuthorisedValues->new()->search( { category => 'av_for_testing', branchcode => $branchcode2 } );
is( @authorised_values, 2, "Search including value with a branch limit ( branch *cannot* use the limited value ) gives correct number of results" );

$av1->del_branch_limitation( $branchcode1 );
@authorised_values = Koha::AuthorisedValues->new()->search( { category => 'av_for_testing', branchcode => $branchcode2 } );
is( @authorised_values, 3, "Branch limitation deleted successfully" );

$av1->add_branch_limitation( $branchcode1 );
$av1->branch_limitations( [ $branchcode1, $branchcode2 ] );

my $limits = $av1->branch_limitations;
is( @$limits, 2, 'branch_limitations functions correctly both as setter and getter' );

my @categories = Koha::AuthorisedValues->new->categories;
is( @categories, 3, 'There should have 2 categories inserted' );
is( $categories[0], $av4->category, 'The first category should be correct (ordered by category name)' );
is( $categories[1], $av1->category, 'The second category should be correct (ordered by category name)' );

subtest 'search_by_*_field + find_by_koha_field + get_description' => sub {
    plan tests => 5;
    my $loc_cat = Koha::AuthorisedValueCategories->find('LOC');
    $loc_cat->delete if $loc_cat;
    my $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => 'c', frameworkcode => '' } );
    $mss->delete if $mss;
    $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => 'c', frameworkcode => 'ACQ' } );
    $mss->delete if $mss;
    $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => 'd', frameworkcode => '' } );
    $mss->delete if $mss;
    $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => '5', frameworkcode => '' } );
    $mss->delete if $mss;
    Koha::AuthorisedValueCategory->new( { category_name => 'LOC' } )->store;
    Koha::AuthorisedValueCategory->new( { category_name => 'ANOTHER_4_TESTS' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => 'c', frameworkcode => '', authorised_value => 'LOC', kohafield => 'items.location' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => 'c', frameworkcode => 'ACQ', authorised_value => 'LOC', kohafield => 'items.location' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => 'd', frameworkcode => '', authorised_value => 'ANOTHER_4_TESTS', kohafield => 'items.another_field' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => '5', frameworkcode => '', authorised_value => 'restricted_for_testing', kohafield => 'items.restricted' } )->store;
    Koha::AuthorisedValue->new( { category => 'LOC', authorised_value => 'location_1' } )->store;
    Koha::AuthorisedValue->new( { category => 'LOC', authorised_value => 'location_2' } )->store;
    Koha::AuthorisedValue->new( { category => 'LOC', authorised_value => 'location_3' } )->store;
    Koha::AuthorisedValue->new( { category => 'ANOTHER_4_TESTS', authorised_value => 'an_av' } )->store;
    Koha::AuthorisedValue->new( { category => 'ANOTHER_4_TESTS', authorised_value => 'another_av' } )->store;
    subtest 'search_by_marc_field' => sub {
        plan tests => 4;
        my $avs;
        $avs = Koha::AuthorisedValues->search_by_marc_field();
        is ( $avs, undef );
        $avs = Koha::AuthorisedValues->search_by_marc_field({ frameworkcode => '' });
        is ( $avs, undef );
        $avs = Koha::AuthorisedValues->search_by_marc_field({ tagfield => 952, tagsubfield => 'c'});
        is( $avs->count, 3, 'default fk');
        is( $avs->next->authorised_value, 'location_1', );
    };
    subtest 'search_by_koha_field' => sub {
        plan tests => 3;
        my $avs;
        $avs = Koha::AuthorisedValues->search_by_koha_field();
        is ( $avs, undef );
        $avs = Koha::AuthorisedValues->search_by_koha_field( { kohafield => 'items.location', tagfield => 952, tagsubfield => 'c' } );
        is( $avs->count,                  3, );
        is( $avs->next->authorised_value, 'location_1', );

    };
    subtest 'find_by_koha_field' => sub {
        plan tests => 3;
        # Test authorised_value = 0
        my $av;
        $av = Koha::AuthorisedValues->find_by_koha_field( { kohafield => 'items.restricted', authorised_value => 0 } );
        is( $av->lib, $av_0->lib, );
        # Test authorised_value = ""
        $av = Koha::AuthorisedValues->find_by_koha_field( { kohafield => 'items.restricted', authorised_value => '' } );
        is( $av->lib, $av_empty_string->lib, );
        # Test authorised_value = undef => we do not want to retrieve anything
        $av = Koha::AuthorisedValues->find_by_koha_field( { kohafield => 'items.restricted', authorised_value => undef } );
        is( $av, undef, );
    };
    subtest 'get_description_by_koha_field' => sub {
        plan tests => 4;
        my $descriptions;

        # Test authorised_value = 0
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
            { kohafield => 'items.restricted', authorised_value => 0 } );
        is_deeply( $descriptions,
            { lib => $av_0->lib, opac_description => $av_0->lib_opac },
        );

        # Test authorised_value = ""
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
            { kohafield => 'items.restricted', authorised_value => '' } );
        is_deeply(
            $descriptions,
            {
                lib              => $av_empty_string->lib,
                opac_description => $av_empty_string->lib_opac
            },
        );

        # Test authorised_value = undef => we do not want to retrieve anything
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
            { kohafield => 'items.restricted', authorised_value => undef } );
        is_deeply( $descriptions, {}, ) ;    # This could be arguable, we could return undef instead

        # No authorised_value
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
            { kohafield => 'items.restricted', authorised_value => "does not exist" } );
        is_deeply( $descriptions, {}, ) ;    # This could be arguable, we could return undef instead
    };
    subtest 'get_descriptions_by_koha_field' => sub {
        plan tests => 1;
        my @descriptions = Koha::AuthorisedValues->get_descriptions_by_koha_field( { kohafield => 'items.restricted' } );
        is_deeply(
            \@descriptions,
            [
                {
                    authorised_value => '',
                    lib              => $av_empty_string->lib,
                    opac_description => $av_empty_string->lib_opac
                },
                {
                    authorised_value => $av_0->authorised_value,
                    lib              => $av_0->lib,
                    opac_description => $av_0->lib_opac
                }
            ],
        );
    };
};

$schema->storage->txn_rollback;
