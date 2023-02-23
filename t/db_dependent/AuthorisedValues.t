#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 16;
use Try::Tiny;

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

my @existing_categories = Koha::AuthorisedValues->new->categories;

# insert
Koha::AuthorisedValueCategory->new({ category_name => 'av_for_testing', is_system => 1 })->store;
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

{ # delete is_system AV categories
    try {
        Koha::AuthorisedValueCategories->find('av_for_testing')->delete
    }
    catch {
        ok(
            $_->isa('Koha::Exceptions::CannotDeleteDefault'),
            'A system AV category cannot be deleted'
        );
    };

    try {
        Koha::AuthorisedValueCategories->search->delete
    }
    catch {
        ok(
            $_->isa('Koha::Exceptions::CannotDeleteDefault'),
            'system AV categories cannot be deleted'
        );
    };
}

is( $av3->opac_description, 'opac display value 3', 'Got correction opac description if lib_opac is set' );
$av3->lib_opac('');
is( $av3->opac_description, 'display value 3', 'Got correction opac description if lib_opac is *not* set' );

my @authorised_values =
  Koha::AuthorisedValues->new()->search( { category => 'av_for_testing' } )->as_list;
is( @authorised_values, 3, "Get correct number of values" );

my $branchcode1 = $builder->build({ source => 'Branch' })->{branchcode};
my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};

$av1->add_library_limit( $branchcode1 );

@authorised_values = Koha::AuthorisedValues->search_with_library_limits( { category => 'av_for_testing' }, {}, $branchcode1 )->as_list;
is( @authorised_values, 3, "Search including value with a branch limit ( branch can use the limited value ) gives correct number of results" );

@authorised_values = Koha::AuthorisedValues->search_with_library_limits( { category => 'av_for_testing' }, {}, $branchcode2 )->as_list;
is( @authorised_values, 2, "Search including value with a branch limit ( branch *cannot* use the limited value ) gives correct number of results" );

$av1->del_library_limit( $branchcode1 );
@authorised_values = Koha::AuthorisedValues->search_with_library_limits( { category => 'av_for_testing' }, {}, $branchcode2 )->as_list;
is( @authorised_values, 3, "Branch limitation deleted successfully" );

$av1->add_library_limit( $branchcode1 );
$av1->library_limits( [ $branchcode1, $branchcode2 ] );

my $limits = $av1->library_limits->as_list;
is( @$limits, 2, 'library_limits functions correctly both as setter and getter' );

my @categories = Koha::AuthorisedValues->new->categories;
is( @categories, @existing_categories+3, 'There should have 3 categories inserted' );
is_deeply(
    \@categories,
    [ sort { uc $a cmp uc $b } @categories ],
    'categories must be ordered by category names'
);

subtest 'search_by_*_field + find_by_koha_field + get_description + authorised_values' => sub {
    plan tests => 6;

    my $test_cat = Koha::AuthorisedValueCategories->find('TEST');
    $test_cat->delete if $test_cat;
    my $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => 'c', frameworkcode => '' } );
    $mss->delete if $mss;
    $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => 'c', frameworkcode => 'ACQ' } );
    $mss->delete if $mss;
    $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => 'd', frameworkcode => '' } );
    $mss->delete if $mss;
    $mss = Koha::MarcSubfieldStructures->search( { tagfield => 952, tagsubfield => '5', frameworkcode => '' } );
    $mss->delete if $mss;
    Koha::AuthorisedValueCategory->new( { category_name => 'TEST' } )->store;
    Koha::AuthorisedValueCategory->new( { category_name => 'ANOTHER_4_TESTS' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => 'c', frameworkcode => '', authorised_value => 'TEST', kohafield => 'items.location' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => 'c', frameworkcode => 'ACQ', authorised_value => 'TEST', kohafield => 'items.location' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => 'd', frameworkcode => '', authorised_value => 'ANOTHER_4_TESTS', kohafield => 'items.another_field' } )->store;
    Koha::MarcSubfieldStructure->new( { tagfield => 952, tagsubfield => '5', frameworkcode => '', authorised_value => 'restricted_for_testing', kohafield => 'items.restricted' } )->store;
    Koha::AuthorisedValue->new( { category => 'TEST', authorised_value => 'location_1', lib => 'location_1' } )->store;
    Koha::AuthorisedValue->new( { category => 'TEST', authorised_value => 'location_2', lib => 'location_2' } )->store;
    Koha::AuthorisedValue->new( { category => 'TEST', authorised_value => 'location_3', lib => 'location_3' } )->store;
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
        $avs = Koha::AuthorisedValues->search_by_koha_field( { kohafield => 'items.location' } );
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
                    authorised_value => $av_0->authorised_value,
                    lib              => $av_0->lib,
                    opac_description => $av_0->lib_opac
                },
                {
                    authorised_value => '',
                    lib              => $av_empty_string->lib,
                    opac_description => $av_empty_string->lib_opac
                }
            ],
        );
    };
    subtest 'authorised_values' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $authorised_value_category =
        $builder->build_object(
            {
                class => 'Koha::AuthorisedValueCategories',
                value => {
                    category_name => 'test_avs'
                }
            }
        );

        is( $authorised_value_category->authorised_values->count, 0, "no authorised values yet" );

        my $av1 = Koha::AuthorisedValue->new(
            {
                category         => 'test_avs',
                authorised_value => 'value 1',
                lib              => 'display value 1',
                lib_opac         => 'opac display value 1',
                imageurl         => 'image1.png',
            }
        )->store();
        is( $authorised_value_category->authorised_values->count, 1, "one authorised value" );

        $schema->storage->txn_rollback;
    };
};

$schema->storage->txn_rollback;
