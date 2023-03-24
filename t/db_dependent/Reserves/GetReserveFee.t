#!/usr/bin/perl

# This script includes tests for GetReserveFee and ChargeReserveFee

# Copyright 2015 Rijksmuseum
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

use Test::More tests => 3;
use Test::MockModule;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation qw( AddIssue );
use C4::Reserves qw( GetReserveFee ChargeReserveFee AddReserve );
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $library = $builder->build({
    source => 'Branch',
});
my $mContext = Test::MockModule->new('C4::Context');
$mContext->mock( 'userenv', sub {
    return { branch => $library->{branchcode} };
});

my $dbh = C4::Context->dbh; # after start transaction of testbuilder

# Category with hold fee, two patrons
$builder->build({
    source => 'Category',
    value  => {
        categorycode          => 'XYZ1',
        reservefee            => 2,
    },
});
$builder->build({
    source => 'Category',
    value  => {
        categorycode          => 'XYZ2',
        reservefee            => 0,
    },
});
my $patron1 = $builder->build({
    source => 'Borrower',
    value  => {
        categorycode => 'XYZ1',
    },
});
my $patron2 = $builder->build({
    source => 'Borrower',
    value  => {
        categorycode => 'XYZ1',
    },
});
my $patron3 = $builder->build({
    source => 'Borrower',
});
my $patron4 = $builder->build({
    source => 'Borrower',
    value  => {
        categorycode => 'XYZ2',
    },
});

# One biblio and two items
my $biblio = $builder->build_sample_biblio;
my $item1 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        notforloan   => 0,
    }
);
my $item2 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        notforloan   => 0,
    }
);

subtest 'GetReserveFee' => sub {
    plan tests => 6;

    C4::Circulation::AddIssue( $patron1, $item1->barcode, '2015-12-31', 0, undef, 0, {} ); # the date does not really matter
    C4::Circulation::AddIssue( $patron3, $item2->barcode, '2015-12-31', 0, undef, 0, {} ); # the date does not really matter
    my $acc2 = acctlines( $patron2->{borrowernumber} );
    my $res1 = addreserve( $patron1->{borrowernumber} );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'not_always');
    my $fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->biblionumber );
    is( $fee > 0, 1, 'Patron 2 should be charged cf GetReserveFee' );
    C4::Reserves::ChargeReserveFee( $patron2->{borrowernumber}, $fee, $biblio->title );
    is( acctlines( $patron2->{borrowernumber} ), $acc2 + 1, 'Patron 2 has been charged by ChargeReserveFee' );

    # If we delete the reserve, there should be no charge
    $dbh->do( "DELETE FROM reserves WHERE borrowernumber = ?", undef, ( $patron1->{borrowernumber}) );
    $fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->biblionumber );
    is( $fee, 0, 'HoldFeeMode=not_always, Patron 2 should not be charged' );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_placed');
    $fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->biblionumber );
    is( int($fee), 2, 'HoldFeeMode=any_time_is_placed, Patron 2 should be charged' );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_collected');
    $fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->biblionumber );
    is( int($fee), 2, 'HoldFeeMode=any_time_is_collected, Patron 2 should be charged' );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_placed');
    $fee = C4::Reserves::GetReserveFee( $patron4->{borrowernumber}, $biblio->biblionumber );
    is( $fee, 0, 'HoldFeeMode=any_time_is_placed ; fee == 0, Patron 4 should not be charged' );
};

subtest 'Integration with AddReserve' => sub {
    plan tests => 2;

    my $dbh = C4::Context->dbh;

    subtest 'Items are not issued' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference('HoldFeeMode', 'not_always');
        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 0, 'not_always - No fee charged for patron 1 if not issued' );

        t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_placed');
        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 1, 'any_time_is_placed - Patron should be always charged' );

        t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_collected');
        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 0, 'any_time_is_collected - Patron should not be charged when placing a hold' );
    };

    subtest 'Items are issued' => sub {
        plan tests => 4;

        $dbh->do( "DELETE FROM issues       WHERE itemnumber=?", undef, $item1->itemnumber);
        $dbh->do( "DELETE FROM issues       WHERE itemnumber=?", undef, $item2->itemnumber);
        C4::Circulation::AddIssue( $patron2, $item1->barcode, '2015-12-31', 0, undef, 0, {} );

        t::lib::Mocks::mock_preference('HoldFeeMode', 'not_always');
        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 0, 'not_always - Patron should not be charged if items are not all checked out' );

        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron3->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 0, 'not_always - Patron should not be charged if all the items are not checked out, even if 1 hold is already placed' );

        C4::Circulation::AddIssue( $patron3, $item2->barcode, '2015-12-31', 0, undef, 0, {} );
        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 0, 'not_always - Patron should not be charged if all items are checked out but no holds are placed' );

        $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
        $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );
        addreserve( $patron3->{borrowernumber} );
        addreserve( $patron1->{borrowernumber} );
        is( acctlines( $patron1->{borrowernumber} ), 1, 'not_always - Patron should only be charged if all items are checked out and at least 1 hold is already placed' );
    };
};

subtest 'Integration with AddIssue' => sub {
    plan tests => 5;

    $dbh->do( "DELETE FROM issues       WHERE borrowernumber = ?", undef, $patron1->{borrowernumber} );
    $dbh->do( "DELETE FROM reserves     WHERE biblionumber=?", undef, $biblio->biblionumber );
    $dbh->do( "DELETE FROM accountlines WHERE borrowernumber=?", undef, $patron1->{borrowernumber} );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'not_always');
    C4::Circulation::AddIssue( $patron1, $item1->barcode, '2015-12-31', 0, undef, 0, {} );
    is( acctlines( $patron1->{borrowernumber} ), 0, 'not_always - Patron should not be charged' );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_placed');
    $dbh->do( "DELETE FROM issues       WHERE borrowernumber = ?", undef, $patron1->{borrowernumber} );
    C4::Circulation::AddIssue( $patron1, $item1->barcode, '2015-12-31', 0, undef, 0, {} );
    is( acctlines( $patron1->{borrowernumber} ), 0, 'not_always - Patron should not be charged' );

    t::lib::Mocks::mock_preference('HoldFeeMode', 'any_time_is_collected');
    $dbh->do( "DELETE FROM issues       WHERE borrowernumber = ?", undef, $patron1->{borrowernumber} );
    C4::Circulation::AddIssue( $patron1, $item1->barcode, '2015-12-31', 0, undef, 0, {} );
    is( acctlines( $patron1->{borrowernumber} ), 0, 'any_time_is_collected - Patron should not be charged when checking out an item which was not placed hold for him' );

    $dbh->do( "DELETE FROM issues       WHERE borrowernumber = ?", undef, $patron1->{borrowernumber} );
    my $id = addreserve( $patron1->{borrowernumber} );
    is( acctlines( $patron1->{borrowernumber} ), 0, 'any_time_is_collected - Patron should not be charged yet (just checking to make sure)');
    C4::Circulation::AddIssue( $patron1, $item1->barcode, '2015-12-31', 0, undef, 0, {} );
    is( acctlines( $patron1->{borrowernumber} ), 1, 'any_time_is_collected - Patron should not be charged when checking out an item which was not placed hold for him' );
};

sub acctlines { #calculate number of accountlines for a patron
    my @temp = $dbh->selectrow_array( "SELECT COUNT(*) FROM accountlines WHERE borrowernumber=?", undef, ( $_[0] ) );
    return $temp[0];
}

sub addreserve {
    return AddReserve(
        {
            branchcode     => $library->{branchcode},
            borrowernumber => $_[0],
            biblionumber   => $biblio->biblionumber,
            priority       => '1',
            title          => $biblio->title,
        }
    );
}

$schema->storage->txn_rollback;

