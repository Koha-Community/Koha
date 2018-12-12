#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use C4::Context;

use Test::More tests => 6;
use MARC::Record;

use Koha::Patrons;
use C4::Biblio;
use C4::Items;
use Koha::Database;

use t::lib::TestBuilder;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build({ source => 'Branch', });
my $library2 = $builder->build({ source => 'Branch', });
my $library3 = $builder->build({ source => 'Branch', });
my $library4 = $builder->build({ source => 'Branch', });
my $itemtype = $builder->build(
    {   source => 'Itemtype',
        value  => { notforloan => undef, rentalcharge => 0 }
    }
)->{itemtype};



my $borrowers_count = 5;

my $biblio = $builder->build_sample_biblio();
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
    {   homebranch    => $library4->{branchcode},
        holdingbranch => $library3->{branchcode},
        itype         => $itemtype
    },
    $biblio->biblionumber,
);


my @branchcodes = ( $library1->{branchcode}, $library2->{branchcode}, $library3->{branchcode}, $library4->{branchcode}, $library3->{branchcode}, $library4->{branchcode} );

my $patron_category = $builder->build({ source => 'Category' });
# Create some borrowers
my @borrowernumbers;
foreach ( 1 .. $borrowers_count ) {
    my $borrowernumber = Koha::Patron->new({
        firstname    => 'my firstname',
        surname      => 'my surname ' . $_,
        categorycode => $patron_category->{categorycode},
        branchcode   => $branchcodes[$_],
    })->store->borrowernumber;
    push @borrowernumbers, $borrowernumber;
}

# Create five item level holds
my $i = 1;
foreach my $borrowernumber (@borrowernumbers) {
    AddReserve(
        $branchcodes[$i],
        $borrowernumber,
        $biblio->biblionumber,
        my $bibitems   = q{},
        my $priority = $i,
        my $resdate,
        my $expdate,
        my $notes = q{},
        'a title',
        my $checkitem,
        my $found,
    );

    $i++;
}

my ($status, $reserve, $all_reserves);

t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 0 );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[0], "Received expected results with LocalHoldsPriority disabled" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[2], "Received expected results with PickupLibrary/homebranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'holdingbranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[1], "Received expected results with PickupLibrary/holdingbranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'holdingbranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[1], "Received expected results with HomeLibrary/holdingbranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[2], "Received expected results with HomeLibrary/homebranch" );
