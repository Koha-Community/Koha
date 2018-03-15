#!/usr/bin/perl

# Copyright 2016 Oslo Public Library
#
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

use Test::More tests => 5;
use t::lib::TestBuilder;

use C4::Reserves qw( ReserveSlip );
use C4::Context;
use Koha::Database;
use Koha::Holds;
my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM reserves|);

my $builder = t::lib::TestBuilder->new();
my $library = $builder->build(
    {
        source => 'Branch',
    }
);

my $patron = $builder->build(
    {
        source => 'Borrower',
        value  => {
            branchcode => $library->{branchcode},
        },
    }
);


my $biblio = $builder->build(
    {
        source => 'Biblio',
        value  => {
            title => 'Title 1',
        },
    }
);

my $item1 = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
        },
    }
);

my $item2 = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
        },
    }
);

my $hold1 = Koha::Hold->new(
    {
        biblionumber   => $biblio->{biblionumber},
        itemnumber     => $item1->{itemnumber},
        waitingdate    => '2000-01-01',
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
    }
)->store;

my $hold2 = Koha::Hold->new(
    {
        biblionumber   => $biblio->{biblionumber},
        itemnumber     => $item2->{itemnumber},
        waitingdate    => '2000-01-01',
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
    }
)->store;

my $letter = $builder->build(
    {
        source => 'Letter',
        value  => {
            module => 'circulation',
            code   => 'HOLD_SLIP',
            lang   => 'default',
            branchcode => $library->{branchcode},
            content => 'Hold found for <<borrowers.firstname>>: Please pick up <<biblio.title>> with barcode <<items.barcode>> at <<branches.branchcode>>.',
            message_transport_type => 'email',
        },
    }
);

is ( ReserveSlip(), undef, "No hold slip returned if invalid or undef borrowernumber and/or biblionumber" );
is ( ReserveSlip({
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->{biblionumber},
    })->{code},
    'HOLD_SLIP', "Get a hold slip from library, patron and biblio" );

is (ReserveSlip({
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->{biblionumber},
    })->{content},
    "Hold found for $patron->{firstname}: Please pick up $biblio->{title} with barcode $item1->{barcode} at $library->{branchcode}.", "Hold slip contains correctly parsed content");

is_deeply(
    ReserveSlip({
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->{biblionumber},
    }),
    ReserveSlip({
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->{biblionumber},
        itemnumber     => $item1->{itemnumber},
        barcode        => $item1->{barcode},
    }),
    "No item as param generate hold slip from first item in reserves");

isnt (
    ReserveSlip({
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->{biblionumber},
    })->{content},
    ReserveSlip({
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->{biblionumber},
        itemnumber     => $item2->{itemnumber},
        barcode        => $item2->{barcode},
    })->{content},
    "Item and/or barcode as params return correct pickup item in hold slip");

$schema->storage->txn_rollback;

1;
