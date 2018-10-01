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

use Test::More tests => 7;

use C4::Circulation;
use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder         = t::lib::TestBuilder->new;
my $library         = $builder->build( { source => 'Branch' } );
my $patron          = $builder->build( { source => 'Borrower', value => { branchcode => $library->{branchcode} } } );
my $item_1          = $builder->build( { source => 'Item' } );
my $item_2          = $builder->build( { source => 'Item' } );
my $nb_of_checkouts = Koha::Checkouts->search->count;
my $new_checkout_1  = Koha::Checkout->new(
    {   borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item_1->{itemnumber},
        branchcode     => $library->{branchcode},
    }
)->store;
my $new_checkout_2 = Koha::Checkout->new(
    {   borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item_2->{itemnumber},
        branchcode     => $library->{branchcode},
    }
)->store;

like( $new_checkout_1->issue_id, qr|^\d+$|, 'Adding a new checkout should have set the issue_id' );
is( Koha::Checkouts->search->count, $nb_of_checkouts + 2, 'The 2 checkouts should have been added' );

my $retrieved_checkout_1 = Koha::Checkouts->find( $new_checkout_1->issue_id );
is( $retrieved_checkout_1->itemnumber, $new_checkout_1->itemnumber, 'Find a checkout by id should return the correct checkout' );

subtest 'is_overdue' => sub {
    plan tests => 6;
    my $ten_days_ago   = dt_from_string->add( days => -10 );
    my $ten_days_later = dt_from_string->add( days => 10 );
    my $yesterday      = dt_from_string->add( days => -1 );
    my $tomorrow       = dt_from_string->add( days => 1 );

    $retrieved_checkout_1->date_due($ten_days_ago)->store;
    is( $retrieved_checkout_1->is_overdue,
        1, 'The item should have been returned 10 days ago' );

    $retrieved_checkout_1->date_due($ten_days_later)->store;
    is( $retrieved_checkout_1->is_overdue, 0, 'The item is due in 10 days' );

    $retrieved_checkout_1->date_due($tomorrow)->store;
    is( $retrieved_checkout_1->is_overdue($ten_days_later),
        1, 'The item should have been returned yesterday' );

    $retrieved_checkout_1->date_due($yesterday)->store;
    is( $retrieved_checkout_1->is_overdue($ten_days_ago),
        0, 'Ten days ago the item due yesterday was not late' );

    $retrieved_checkout_1->date_due($tomorrow)->store;
    is( $retrieved_checkout_1->is_overdue($ten_days_later),
        1, 'In Ten days, the item due tomorrow will be late' );

    $retrieved_checkout_1->date_due($yesterday)->store;
    is( $retrieved_checkout_1->is_overdue($ten_days_ago),
        0, 'In Ten days, the item due yesterday will still be late' );
};

subtest 'item' => sub {
    plan tests => 2;
    my $item = $retrieved_checkout_1->item;
    is( ref( $item ), 'Koha::Item', 'Koha::Checkout->item should return a Koha::Item' );
    is( $item->itemnumber, $item_1->{itemnumber}, 'Koha::Checkout->item should return the correct item' );
};

subtest 'patron' => sub {
    plan tests => 3;
    my $patron = $builder->build_object({class=>'Koha::Patrons', value => {branchcode => $library->{branchcode}}});

    my $item = $builder->build_object( { class=> 'Koha::Items' } );
    my $checkout = Koha::Checkout->new(
        {   borrowernumber => $patron->borrowernumber,
            itemnumber     => $item->itemnumber,
            branchcode     => $library->{branchcode},
        }
    )->store;

    my $p = $checkout->patron;
    is( ref($p), 'Koha::Patron',
        'Koha::Checkout->patron should return a Koha::Patron' );
    is( $p->borrowernumber, $patron->borrowernumber,
        'Koha::Checkout->patron should return the correct patron' );

    # Testing Koha::Old::Checkout->patron now
    my $issue_id = $checkout->issue_id;
    C4::Circulation::MarkIssueReturned( $p->borrowernumber, $checkout->itemnumber );
    $p->delete;
    my $old_issue = Koha::Old::Checkouts->find($issue_id);
    is( $old_issue->patron, undef,
        'Koha::Checkout->patron should return undef if the patron record has been deleted'
    );
};

$retrieved_checkout_1->delete;
is( Koha::Checkouts->search->count, $nb_of_checkouts + 1, 'Delete should have deleted the checkout' );

$schema->storage->txn_rollback;

