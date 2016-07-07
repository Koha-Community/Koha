#!/usr/bin/perl

# Copyright 2016 Koha Development team
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

use Test::More tests => 2;

use Koha::Item::Transfer;
use Koha::Item::Transfers;
use Koha::Database;
use Koha::DateUtils;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder      = t::lib::TestBuilder->new;
my $library_from = $builder->build( { source => 'Branch' } );
my $library_to   = $builder->build( { source => 'Branch' } );
my $item         = $builder->build( { source => 'Item', value => { holding_branch => $library_from->{branchcode}, homebranch => $library_to->{branchcode} } } );

my $nb_of_transfers = Koha::Item::Transfers->search->count;
my $new_transfer_1  = Koha::Item::Transfer->new(
    {   itemnumber  => $item->{itemnumber},
        frombranch  => $library_from->{branchcode},
        tobranch    => $library_to->{branchcode},
        datearrived => dt_from_string,
        datesent    => dt_from_string,
    }
)->store;
my $new_transfer_2 = Koha::Item::Transfer->new(
    {   itemnumber  => $item->{itemnumber},
        frombranch  => $library_from->{branchcode},
        tobranch    => $library_to->{branchcode},
        datearrived => undef,
        datesent    => dt_from_string,
    }
)->store;

is( Koha::Item::Transfers->search->count, $nb_of_transfers + 2, 'The 2 transfers should have been added' );

my $retrieved_transfer_1 = Koha::Item::Transfers->search( { itemnumber => $new_transfer_1->itemnumber })->next;
is( $retrieved_transfer_1->itemnumber, $new_transfer_1->itemnumber, 'Find a transfer by id should return the correct transfer' );

# FIXME: This does not pass and should be fixed later
# "Operation requires a primary key to be declared on 'Branchtransfer' via set_primary_key"
#$retrieved_transfer_1->delete;
#is( Koha::Item::Transfers->search->count, $nb_of_transfers + 1, 'Delete should have deleted the transfer' );

$schema->storage->txn_rollback;

1;
