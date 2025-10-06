#!/usr/bin/perl

# This file is part of Koha.
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
use Test::More tests => 3;

use C4::Circulation qw( AddReturn );
use C4::Context;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'Test StoreLastBorrower' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '1' );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item;

    my $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->itemnumber,
            },
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    $item = $item->get_from_storage;
    my $patron_object = $item->last_returned_by();
    is( $patron_object, undef, 'Koha::Item::last_returned_by returned undef' );

    my ( $returned, undef, undef ) =
        C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string('2010-10-10') );

    $item          = $item->get_from_storage;
    $patron_object = $item->last_returned_by();
    is( ref($patron_object), 'Koha::Patron', 'Koha::Item::last_returned_by returned Koha::Patron' );

    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );

    $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->itemnumber,
            },
        }
    );

    ( $returned, undef, undef ) =
        C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string('2010-10-10') );

    $item          = $item->get_from_storage;
    $patron_object = $item->last_returned_by();
    is( $patron_object->id, $patron->{borrowernumber}, 'Second patron to return item replaces the first' );

    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );
    $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );

    $item->last_returned_by( $patron_object->borrowernumber );
    $item = $item->get_from_storage;
    my $patron_object2 = $item->last_returned_by();
    is(
        $patron_object->id, $patron_object2->id,
        'Calling last_returned_by with Borrower object sets last_returned_by to that borrower'
    );

    $patron_object->delete;
    $item = $item->get_from_storage;
    is(
        $item->last_returned_by, undef,
        'last_returned_by should return undef if the last patron to return the item has been deleted'
    );

    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '0' );
    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );

    $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->itemnumber,
            },
        }
    );
    ( $returned, undef, undef ) =
        C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string('2010-10-10') );

    $item = $item->get_from_storage;
    is( $item->last_returned_by, undef, 'Last patron to return item should not be stored if StoreLastBorrower if off' );
};

subtest 'Test StoreLastBorrower with multiple borrowers' => sub {
    plan tests => 12;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item;
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Test last_returned_by_all with no borrowers
    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '3' );
    my $borrowers = $item->last_returned_by_all();
    is( $borrowers->count, 0, 'last_returned_by_all returns empty set when no borrowers stored' );

    # Add 3 borrowers for testing, checkout/check in
    my @patrons;
    for my $i ( 1 .. 3 ) {
        my $patron = $builder->build(
            {
                source => 'Borrower',
                value  => { privacy => 1, branchcode => $library->branchcode }
            }
        );
        push @patrons, $patron;

        my $issue = $builder->build(
            {
                source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->itemnumber,
                },
            }
        );

        my ( $returned, undef, undef ) =
            C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string("2010-10-1$i") );
    }

    $item = $item->get_from_storage;

    # Test last_returned_by_all returns all borrowers
    $borrowers = $item->last_returned_by_all();
    is( $borrowers->count, 3, 'Correctly returns 3 borrowers' );

    # Test ordering
    my @borrowers_array = $borrowers->as_list;
    is( $borrowers_array[0]->borrowernumber, $patrons[2]->{borrowernumber}, 'Most recent borrower first' );
    is( $borrowers_array[1]->borrowernumber, $patrons[1]->{borrowernumber}, 'Second most recent borrower second' );
    is( $borrowers_array[2]->borrowernumber, $patrons[0]->{borrowernumber}, 'Oldest borrower last' );

    # Add 2 more borrowers/check out/check in
    for my $i ( 4 .. 5 ) {
        my $patron = $builder->build(
            {
                source => 'Borrower',
                value  => { privacy => 1, branchcode => $library->branchcode }
            }
        );
        push @patrons, $patron;

        my $issue = $builder->build(
            {
                source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->itemnumber,
                },
            }
        );

        my ( $returned, undef, undef ) =
            C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string("2010-10-1$i") );
    }

    $item      = $item->get_from_storage;
    $borrowers = $item->last_returned_by_all();
    is(
        $borrowers->count, 3,
        'We only retain 3 borrowers when the sys pref is set to 3, even though there are 5 checkouts/checkins'
    );
    @borrowers_array = $borrowers->as_list;
    is( $borrowers_array[0]->borrowernumber, $patrons[4]->{borrowernumber}, 'Most recent borrower after cleanup' );

    # Reduce StoreLastBorrower to 2
    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '2' );

    my $yet_another_patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, branchcode => $library->branchcode }
        }
    );

    my $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $yet_another_patron->{borrowernumber},
                itemnumber     => $item->itemnumber,
            },
        }
    );

    my ( $returned, undef, undef ) = C4::Circulation::AddReturn(
        $item->barcode, $yet_another_patron->{branchcode}, undef,
        dt_from_string('2010-10-16')
    );

    $item      = $item->get_from_storage;
    $borrowers = $item->last_returned_by_all();
    is( $borrowers->count, 2, 'StoreLastBorrower was reduced to 2, we should now only keep 2 in the table' );
    @borrowers_array = $borrowers->as_list;
    is(
        $borrowers_array[0]->borrowernumber, $yet_another_patron->{borrowernumber},
        'Most recent borrower after limit reduction'
    );

    # Disabled pref
    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '0' );

    # If pref has become disabled, nothing should be stored in the table
    my $one_more_patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, branchcode => $library->branchcode }
        }
    );

    my $another_issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $one_more_patron->{borrowernumber},
                itemnumber     => $item->itemnumber,
            },
        }
    );

    ( $returned, undef, undef ) = C4::Circulation::AddReturn(
        $item->barcode, $one_more_patron->{branchcode}, undef,
        dt_from_string('2010-10-18')
    );

    $item      = $item->get_from_storage;
    $borrowers = $item->last_returned_by_all();
    is( $borrowers->count, 0, 'last_returned_by_all respects preference value 0' );

    my $cleanup_patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, branchcode => $library->branchcode }
        }
    );

    $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $cleanup_patron->{borrowernumber},
                itemnumber     => $item->itemnumber,
            },
        }
    );

    ( $returned, undef, undef ) = C4::Circulation::AddReturn(
        $item->barcode, $cleanup_patron->{branchcode}, undef,
        dt_from_string('2010-10-17')
    );

    $item      = $item->get_from_storage;
    $borrowers = $item->last_returned_by_all();
    is( $borrowers->count,       0,     'All entries cleared when preference is 0' );
    is( $item->last_returned_by, undef, 'last_returned_by returns undef when no records' );

};

$schema->storage->txn_rollback;

