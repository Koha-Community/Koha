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

use Test::More tests => 6;
use Test::MockModule;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation;
use C4::Reserves qw|AddReserve|;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $library = $builder->build({
    source => 'Branch',
});
my $mContext = new Test::MockModule('C4::Context');
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

# One biblio and two items
my $biblio = $builder->build({
    source => 'Biblio',
    value  => {
        title => 'Title 1',
    },
});
my $item1 = $builder->build({
    source => 'Item',
    value  => {
        biblionumber => $biblio->{biblionumber},
    },
});
my $item2 = $builder->build({
    source => 'Item',
    value  => {
        biblionumber => $biblio->{biblionumber},
    },
});


# Actual testing starts here!
# Add reserve for patron1, no fee expected
# Note: AddReserve calls GetReserveFee and ChargeReserveFee
my $acc1 = acctlines( $patron1->{borrowernumber} );
my $res1 = addreserve( $patron1->{borrowernumber} );
is( acctlines( $patron1->{borrowernumber} ), $acc1, 'No fee charged for patron 1' );

# Issue item1 to patron1. Since there is still a reserve too, we should
# expect a charge for patron2.
C4::Circulation::AddIssue( $patron1, $item1->{barcode}, '2015-12-31', 0, undef, 0, {} ); # the date does not really matter
my $acc2 = acctlines( $patron2->{borrowernumber} );
t::lib::Mocks::mock_preference('HoldFeeMode', 'not_always');
my $fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->{biblionumber} );
is( $fee > 0, 1, 'Patron 2 should be charged cf GetReserveFee' );
C4::Reserves::ChargeReserveFee( $patron2->{borrowernumber}, $fee, $biblio->{title} );
is( acctlines( $patron2->{borrowernumber} ), $acc2 + 1, 'Patron 2 has been charged by ChargeReserveFee' );

# If we delete the reserve, there should be no charge
$dbh->do( "DELETE FROM reserves WHERE reserve_id=?", undef, ( $res1 ) );
$fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->{biblionumber} );
is( $fee, 0, 'HoldFeeMode=not_always, Patron 2 should not be charged' );

t::lib::Mocks::mock_preference('HoldFeeMode', 'always');
$fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->{biblionumber} );
is( int($fee), 2, 'HoldFeeMode=always, Patron 2 should be charged' );

# If we delete the second item, there should be a charge
$dbh->do( "DELETE FROM items WHERE itemnumber=?", undef, ( $item2->{itemnumber} ) );
$fee = C4::Reserves::GetReserveFee( $patron2->{borrowernumber}, $biblio->{biblionumber} );
is( int($fee), 2, 'Patron 2 should be charged again this time' );
# End of tests

sub acctlines { #calculate number of accountlines for a patron
    my @temp = $dbh->selectrow_array( "SELECT COUNT(*) FROM accountlines WHERE borrowernumber=?", undef, ( $_[0] ) );
    return $temp[0];
}

sub addreserve {
    return AddReserve(
        $library->{branchcode},
        $_[0],
        $biblio->{biblionumber},
        undef,
        '1',
        undef,
        undef,
        '',
        $biblio->{title},
        undef,
        ''
    );
}

$schema->storage->txn_rollback;

1;
