#!/usr/bin/perl

# Copyright The National Library of Finland, University of Helsinki 2020
# Copyright Petro Vashchuk <stalkernoid@gmail.com> 2020
#
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

use C4::Context;
use Koha::CirculationRules;

use Test::More tests => 13;

use t::lib::TestBuilder;
use t::lib::Mocks;
use Koha::Holds;

use Koha::Account;
use Koha::Account::DebitTypes;

BEGIN {
    use_ok('C4::Reserves');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});

my $bib_title = "Test Title";

my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library1->{branchcode},
    }
});

my $itemtype1 = $builder->build({
    source => 'Itemtype',
    value => {}
});
my $itemtype2 = $builder->build({
    source => 'Itemtype',
    value => {}
});
my $itemtype3 = $builder->build({
    source => 'Itemtype',
    value => {}
});
my $itemtype4 = $builder->build({
    source => 'Itemtype',
    value => {}
});

my $borrowernumber = $borrower->{borrowernumber};

my $library_A_code = $library1->{branchcode};

my $biblio = $builder->build_sample_biblio({itemtype => $itemtype1->{itemtype}});
my $biblionumber = $biblio->biblionumber;
my $item1 = $builder->build_sample_item({
    biblionumber => $biblionumber,
    itype => $itemtype1->{itemtype},
    homebranch => $library_A_code,
    holdingbranch => $library_A_code
});
my $item2 = $builder->build_sample_item({
    biblionumber => $biblionumber,
    itype => $itemtype2->{itemtype},
    homebranch => $library_A_code,
    holdingbranch => $library_A_code
});
my $item3 = $builder->build_sample_item({
    biblionumber => $biblionumber,
    itype => $itemtype3->{itemtype},
    homebranch => $library_A_code,
    holdingbranch => $library_A_code
});

my $library_B_code = $library2->{branchcode};

my $biblio2 = $builder->build_sample_biblio({itemtype => $itemtype4->{itemtype}});
my $biblionumber2 = $biblio2->biblionumber;
my $item4 = $builder->build_sample_item({
    biblionumber => $biblionumber2,
    itype => $itemtype4->{itemtype},
    homebranch => $library_B_code,
    holdingbranch => $library_B_code
});

$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        itemtype     => $itemtype1->{itemtype},
        categorycode => undef,
        branchcode   => undef,
        rules        => {
            expire_reserves_charge => '111'
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        itemtype     => $itemtype2->{itemtype},
        categorycode => undef,
        branchcode   => undef,
        rules        => {
            expire_reserves_charge => undef
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        itemtype     => undef,
        categorycode => undef,
        branchcode   => $library_B_code,
        rules        => {
            expire_reserves_charge => '444'
        }
    }
);

t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');

my $reserve_id;
my $account;
my $status;
my $start_balance;

# TEST: Hold itemtype1 item
$reserve_id = AddReserve(
    {
        branchcode       => $library_A_code,
        borrowernumber   => $borrowernumber,
        biblionumber     => $biblionumber,
        priority         => 1,
        itemnumber       => $item1->itemnumber,
    }
);

$account = Koha::Account->new({ patron_id => $borrowernumber });

( $status ) = CheckReserves($item1->id);
is( $status, 'Reserved', "Hold for the itemtype1 created" );

$start_balance = $account->balance();

Koha::Holds->find( $reserve_id )->cancel({ charge_cancel_fee => 1 });

( $status ) = CheckReserves($item1->id);
is( $status, '', "Hold for the itemtype1 cancelled" );

is( $account->balance() - $start_balance, 111, "Used circulation rule for itemtype1" );

# TEST: circulation rule for itemtype2 has 'expire_reserves_charge' set undef, so it should use ExpireReservesMaxPickUpDelayCharge preference
t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 222);

$reserve_id = AddReserve(
    {
        branchcode       => $library_A_code,
        borrowernumber   => $borrowernumber,
        biblionumber     => $biblionumber,
        priority         => 1,
        itemnumber       => $item2->itemnumber,
    }
);

$account = Koha::Account->new({ patron_id => $borrowernumber });

( $status ) = CheckReserves($item2->id);
is( $status, 'Reserved', "Hold for the itemtype2 created" );

$start_balance = $account->balance();

Koha::Holds->find( $reserve_id )->cancel({ charge_cancel_fee => 1 });

( $status ) = CheckReserves($item2->id);
is( $status, '', "Hold for the itemtype2 cancelled" );

is( $account->balance() - $start_balance, 222, "Used ExpireReservesMaxPickUpDelayCharge preference as expire_reserves_charge set to undef" );

# TEST: no circulation rules for itemtype3, it should use ExpireReservesMaxPickUpDelayCharge preference
t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 333);

$reserve_id = AddReserve(
    {
        branchcode       => $library_A_code,
        borrowernumber   => $borrowernumber,
        biblionumber     => $biblionumber,
        priority         => 1,
        itemnumber       => $item3->itemnumber,
    }
);

$account = Koha::Account->new({ patron_id => $borrowernumber });

( $status ) = CheckReserves($item3->id);
is( $status, 'Reserved', "Hold for the itemtype3 created" );

$start_balance = $account->balance();

Koha::Holds->find( $reserve_id )->cancel({ charge_cancel_fee => 1 });

( $status ) = CheckReserves($item3->id);
is( $status, '', "Hold for the itemtype3 cancelled" );

is( $account->balance() - $start_balance, 333, "Used ExpireReservesMaxPickUpDelayCharge preference as there's no circulation rules for itemtype3" );

# TEST: circulation rule for itemtype4 with library_B_code
t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 555);

$reserve_id = AddReserve(
    {
        branchcode       => $library_B_code,
        borrowernumber   => $borrowernumber,
        biblionumber     => $biblionumber2,
        priority         => 1,
        itemnumber       => $item4->itemnumber,
    }
);

$account = Koha::Account->new({ patron_id => $borrowernumber });

( $status ) = CheckReserves($item4->id);
is( $status, 'Reserved', "Hold for the itemtype4 created" );

$start_balance = $account->balance();

Koha::Holds->find( $reserve_id )->cancel({ charge_cancel_fee => 1 });

( $status ) = CheckReserves($item4->id);
is( $status, '', "Hold for the itemtype4 cancelled" );

is( $account->balance() - $start_balance, 444, "Used circulation rule for itemtype4 with library_B_code" );

$schema->storage->txn_rollback;
