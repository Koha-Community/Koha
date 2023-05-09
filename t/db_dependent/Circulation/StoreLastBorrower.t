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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 1;

use C4::Circulation qw( AddReturn );
use C4::Context;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'Test StoreLastBorrower' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '1' );

    my $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
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

    $item = $item->get_from_storage;
    my $patron_object = $item->last_returned_by();
    is( $patron_object, undef, 'Koha::Item::last_returned_by returned undef' );

    my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode},  undef, dt_from_string('2010-10-10') );

    $item = $item->get_from_storage;
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

    ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string('2010-10-10') );

    $item = $item->get_from_storage;
    $patron_object = $item->last_returned_by();
    is( $patron_object->id, $patron->{borrowernumber}, 'Second patron to return item replaces the first' );

    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );
    $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );

    $item->last_returned_by($patron_object->borrowernumber);
    $item = $item->get_from_storage;
    my $patron_object2 = $item->last_returned_by();
    is( $patron_object->id, $patron_object2->id,
        'Calling last_returned_by with Borrower object sets last_returned_by to that borrower' );

    $patron_object->delete;
    $item = $item->get_from_storage;
    is( $item->last_returned_by, undef, 'last_returned_by should return undef if the last patron to return the item has been deleted' );

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
    ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->barcode, $patron->{branchcode}, undef, dt_from_string('2010-10-10') );

    $item = $item->get_from_storage;
    is( $item->last_returned_by, undef, 'Last patron to return item should not be stored if StoreLastBorrower if off' );
};

$schema->storage->txn_rollback;

