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

use Test::More tests => 4;

use Koha::Checkout;
use Koha::Checkouts;
use Koha::Database;

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

$retrieved_checkout_1->delete;
is( Koha::Checkouts->search->count, $nb_of_checkouts + 1, 'Delete should have deleted the checkout' );

$schema->storage->txn_rollback;

1;
