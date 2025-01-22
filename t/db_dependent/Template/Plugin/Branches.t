#!/usr/bin/perl

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
use Test::More tests => 5;
use Test::MockModule;

use C4::Context;
use C4::Biblio qw(AddBiblio);
use Koha::Database;

use Clone           qw(clone);
use List::MoreUtils qw(any);

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::Branches');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'all() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    my $library = $builder->build(
        {
            source => 'Branch',
            value  => {
                branchcode => 'MYLIBRARY',
                branchname => 'My sweet library'
            }
        }
    );
    my $another_library = $builder->build(
        {
            source => 'Branch',
            value  => {
                branchcode => 'ANOTHERLIB',
            }
        }
    );

    my $plugin = Koha::Template::Plugin::Branches->new();
    ok( $plugin, "initialized Branches plugin" );

    my $name = $plugin->GetName( $library->{branchcode} );
    is( $name, $library->{branchname}, 'retrieved expected name for library' );

    $name = $plugin->GetName('__ANY__');
    is( $name, '', 'received empty string as name of the "__ANY__" placeholder library code' );

    $name = $plugin->GetName(undef);
    is( $name, '', 'received empty string as name of NULL/undefined library code' );

    $name = $plugin->GetName(q{});
    is( $name, '', 'received empty string as name of empty string library code' );

    is( $plugin->GetLoggedInBranchcode(), '', 'no active library code if there is no active user session' );
    is( $plugin->GetLoggedInBranchname(), '', 'no active library name if there is no active user session' );

    t::lib::Mocks::mock_userenv( { branchcode => 'MYLIBRARY', branchname => 'My sweet library' } );
    is( $plugin->GetLoggedInBranchcode(), 'MYLIBRARY',        'GetLoggedInBranchcode() returns active library code' );
    is( $plugin->GetLoggedInBranchname(), 'My sweet library', 'GetLoggedInBranchname() returns active library name' );

    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );
    my $libraries = $plugin->all();
    ok( scalar(@$libraries) > 1, 'If IndependentBranches is not set, all libraries should be returned' );
    is(
        grep ( { $_->{branchcode} eq 'MYLIBRARY' and $_->{selected} == 1 } @$libraries ), 1,
        'Without selected parameter, my library should be preselected'
    );
    is(
        grep ( { $_->{branchcode} eq 'ANOTHERLIB' and not exists $_->{selected} } @$libraries ), 1,
        'Without selected parameter, other library should not be preselected'
    );
    $libraries = $plugin->all( { selected => 'ANOTHERLIB' } );
    is(
        grep ( { $_->{branchcode} eq 'MYLIBRARY' and not exists $_->{selected} } @$libraries ), 1,
        'With selected parameter, my library should not be preselected'
    );
    is(
        grep ( { $_->{branchcode} eq 'ANOTHERLIB' and $_->{selected} == 1 } @$libraries ), 1,
        'With selected parameter, other library should be preselected'
    );
    $libraries = $plugin->all( { selected => '' } );
    is(
        grep ( { exists $_->{selected} } @$libraries ), 0,
        'With selected parameter set to an empty string, no library should be preselected'
    );

    my $total               = @{ $plugin->all };
    my $pickupable          = @{ $plugin->all( { search_params => { pickup_location => 1 } } ) };
    my $yet_another_library = $builder->build(
        {
            source => 'Branch',
            value  => {
                branchcode      => 'CANTPICKUP',
                pickup_location => 0,
            }
        }
    );
    is(
        @{ $plugin->all( { search_params => { pickup_location => 1 } } ) }, $pickupable,
        'Adding a new library with pickups' . ' disabled does not increase the amount returned by ->pickup_locations'
    );
    is(
        @{ $plugin->all }, $total + 1,
        'However, adding a new library increases' . ' the total amount gotten with ->all'
    );

    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
    $libraries = $plugin->all();
    is( scalar(@$libraries), 1, 'If IndependentBranches is set, only 1 library should be returned' );
    $libraries = $plugin->all( { unfiltered => 1 } );
    ok(
        scalar(@$libraries) > 1,
        'If IndependentBranches is set, all libraries should be returned if the unfiltered flag is set'
    );

    $schema->storage->txn_rollback;
};

subtest 'pickup_locations() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    Koha::Libraries->search->update( { pickup_location => 0 } );

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library_3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );

    my $plugin           = Koha::Template::Plugin::Branches->new();
    my $pickup_locations = $plugin->pickup_locations();

    is( scalar @{$pickup_locations}, 3, 'Libraries count is correct' );

    $pickup_locations = $plugin->pickup_locations( { search_params => { item => undef } } );
    is( scalar @{$pickup_locations}, 3, 'item parameter not a ref, fallback to general search' );

    $pickup_locations = $plugin->pickup_locations( { search_params => { biblio => undef } } );
    is( scalar @{$pickup_locations}, 3, 'biblio parameter not a ref, fallback to general search' );

    my $item_class = Test::MockModule->new('Koha::Item');
    $item_class->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => $library_1->branchcode } );
        }
    );

    my $item   = $builder->build_sample_item();
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    $pickup_locations =
        $plugin->pickup_locations( { search_params => { item => $item, patron => Koha::Patron->new } } );

    is( scalar @{$pickup_locations},          1, 'Only the library returned by $item->pickup_locations is returned' );
    is( $pickup_locations->[0]->{branchcode}, $library_1->branchcode, 'Not cheating' );

    my $biblio_class = Test::MockModule->new('Koha::Biblio');
    $biblio_class->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => $library_2->branchcode } );
        }
    );

    my $biblio = $builder->build_sample_biblio();

    $pickup_locations =
        $plugin->pickup_locations( { search_params => { biblio => $biblio, patron => Koha::Patron->new } } );

    is( scalar @{$pickup_locations},          1, 'Only the library returned by $biblio->pickup_locations is returned' );
    is( $pickup_locations->[0]->{branchcode}, $library_2->branchcode, 'Not cheating' );

    subtest 'Koha::Item->pickup_locations and Koha::Biblio->pickup_locations empty tests' => sub {

        plan tests => 2;

        my $biblio_class = Test::MockModule->new('Koha::Biblio');
        $biblio_class->mock( 'pickup_locations', sub { return Koha::Libraries->new->empty } );

        my $biblio = $builder->build_sample_biblio;

        my @pickup_locations = @{ $plugin->pickup_locations( { search_params => { biblio => $biblio->id } } ) };
        is( scalar @pickup_locations, 0, 'No pickup locations returned' );

        my $item_class = Test::MockModule->new('Koha::Item');
        $item_class->mock( 'pickup_locations', sub { return Koha::Libraries->new->empty } );

        my $item = $builder->build_sample_item;

        @pickup_locations = @{ $plugin->pickup_locations( { search_params => { item => $item->id } } ) };
        is( scalar @pickup_locations, 0, 'No pickup locations returned' );
    };

    subtest 'selected tests' => sub {

        plan tests => 4;

        t::lib::Mocks::mock_userenv( { branchcode => $library_2->branchcode } );

        $pickup_locations = $plugin->pickup_locations();

        is( scalar @{$pickup_locations}, 3, 'Libraries count is correct' );
        foreach my $pickup_location ( @{$pickup_locations} ) {
            next unless exists $pickup_location->{selected} and $pickup_location->{selected} == 1;
            is( $pickup_location->{branchcode}, $library_2->branchcode, 'The right library is marked as selected' );
        }

        $pickup_locations = $plugin->pickup_locations( { selected => $library_3->branchcode } );

        is( scalar @{$pickup_locations}, 3, 'Libraries count is correct' );
        foreach my $pickup_location ( @{$pickup_locations} ) {
            next unless exists $pickup_location->{selected} and $pickup_location->{selected} == 1;
            is( $pickup_location->{branchcode}, $library_3->branchcode, 'The right library is marked as selected' );
        }
    };

    $schema->storage->txn_rollback;
};

subtest 'branch specific js and css' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $newbranch_with = $builder->build(
        {
            source => 'Branch',
            value  => {
                opacuserjs  => 'console.log(\'Hello World\');',
                opacusercss => 'body { background-color: blue; }'
            }
        }
    );
    my $newbranch_none = $builder->build(
        {
            source => 'Branch',
            value  => {
                opacuserjs  => '',
                opacusercss => ''
            }
        }
    );

    my $plugin = Koha::Template::Plugin::Branches->new();

    my $opacuserjs = $plugin->GetBranchSpecificJS( $newbranch_with->{branchcode} );
    is( $opacuserjs, $newbranch_with->{opacuserjs}, 'received correct JS string from function' );

    my $opacusercss = $plugin->GetBranchSpecificCSS( $newbranch_with->{branchcode} );
    is( $opacusercss, $newbranch_with->{opacusercss}, 'received correct CSS string from function' );

    $opacuserjs  = $plugin->GetBranchSpecificJS( $newbranch_none->{branchcode} );
    $opacusercss = $plugin->GetBranchSpecificCSS( $newbranch_none->{branchcode} );
    is( $opacuserjs,  q{}, 'received correct blank string from function when branch has none' );
    is( $opacusercss, q{}, 'received correct blank string from function when branch has none' );

    $opacuserjs  = $plugin->GetBranchSpecificJS();
    $opacusercss = $plugin->GetBranchSpecificCSS();
    is( $opacuserjs,  q{}, 'received correct blank string from function when no branch set' );
    is( $opacusercss, q{}, 'received correct blank string from function when no branch set' );

    $schema->storage->txn_rollback;
};
