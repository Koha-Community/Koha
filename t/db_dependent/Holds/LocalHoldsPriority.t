#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use C4::Context;

use Test::More tests => 7;
use MARC::Record;

use Koha::Patrons;
use Koha::Holds;
use C4::Biblio;
use C4::Items;
use Koha::Database;

use t::lib::TestBuilder;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves', qw( AddReserve CheckReserves ));
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
my $item = Koha::Item->new(
    {
        biblionumber  => $biblio->biblionumber,
        homebranch    => $library4->{branchcode},
        holdingbranch => $library3->{branchcode},
        itype         => $itemtype,
        exclude_from_local_holds_priority => 0,
    },
)->store;

my @branchcodes = ( $library1->{branchcode}, $library2->{branchcode}, $library3->{branchcode}, $library4->{branchcode}, $library3->{branchcode}, $library4->{branchcode} );
my $patron_category = $builder->build({ source => 'Category', value => {exclude_from_local_holds_priority => 0} });
# Create some borrowers
my @borrowernumbers;
foreach ( 0 .. $borrowers_count-1 ) {
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
        {
            branchcode     => $branchcodes[$i],
            borrowernumber => $borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => $i,
        }
    );

    $i++;
}

my ($status, $reserve, $all_reserves);

t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 0 );
($status, $reserve, $all_reserves) = CheckReserves($item);
ok( $reserve->{borrowernumber} eq $borrowernumbers[0], "Received expected results with LocalHoldsPriority disabled" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
($status, $reserve, $all_reserves) = CheckReserves($item);
ok( $reserve->{borrowernumber} eq $borrowernumbers[2], "Received expected results with PickupLibrary/homebranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'holdingbranch' );
($status, $reserve, $all_reserves) = CheckReserves($item);
ok( $reserve->{borrowernumber} eq $borrowernumbers[1], "Received expected results with PickupLibrary/holdingbranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'holdingbranch' );
($status, $reserve, $all_reserves) = CheckReserves($item);
ok( $reserve->{borrowernumber} eq $borrowernumbers[2], "Received expected results with HomeLibrary/holdingbranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
($status, $reserve, $all_reserves) = CheckReserves($item);
ok( $reserve->{borrowernumber} eq $borrowernumbers[3], "Received expected results with HomeLibrary/homebranch" );

$schema->storage->txn_rollback;

subtest "exclude from local holds" => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );

    my $category_ex = $builder->build_object({ class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 1} });
    my $category_nex = $builder->build_object({ class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });

    my $lib1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $lib2 = $builder->build_object({ class => 'Koha::Libraries' });

    my $item1 = $builder->build_sample_item({exclude_from_local_holds_priority => 0, homebranch => $lib1->branchcode});
    my $item2 = $builder->build_sample_item({exclude_from_local_holds_priority => 1, homebranch => $lib1->branchcode});

    my $patron_ex_l2 = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib2->branchcode, categorycode => $category_ex->categorycode}});
    my $patron_ex_l1 = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib1->branchcode, categorycode => $category_ex->categorycode}});
    my $patron_nex_l2 = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib2->branchcode, categorycode => $category_nex->categorycode}});
    my $patron_nex_l1 = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib1->branchcode, categorycode => $category_nex->categorycode}});

    AddReserve(
        {
            branchcode     => $patron_nex_l2->branchcode,
            borrowernumber => $patron_nex_l2->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 1,
        }
    );
    AddReserve(
        {
            branchcode     => $patron_ex_l1->branchcode,
            borrowernumber => $patron_ex_l1->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 2,
        }
    );
    AddReserve(
        {
            branchcode     => $patron_nex_l1->branchcode,
            borrowernumber => $patron_nex_l1->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 3,
        }
    );

    my ($status, $reserve, $all_reserves);
    ($status, $reserve, $all_reserves) = CheckReserves($item1);
    is($reserve->{borrowernumber}, $patron_nex_l1->borrowernumber, "Patron not excluded with local holds priorities is next checkout");

    Koha::Holds->delete;

    AddReserve(
        {
            branchcode     => $patron_nex_l2->branchcode,
            borrowernumber => $patron_nex_l2->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 1,
        }
    );
    AddReserve(
        {
            branchcode     => $patron_ex_l1->branchcode,
            borrowernumber => $patron_ex_l1->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 2,
        }
    );

    ($status, $reserve, $all_reserves) = CheckReserves($item1);
    is($reserve->{borrowernumber}, $patron_nex_l2->borrowernumber, "Local patron is excluded from priority");

    Koha::Holds->delete;

    AddReserve(
        {
            branchcode     => $patron_nex_l2->branchcode,
            borrowernumber => $patron_nex_l2->borrowernumber,
            biblionumber   => $item2->biblionumber,
            priority       => 1,
        }
    );
    AddReserve(
        {
            branchcode     => $patron_nex_l1->branchcode,
            borrowernumber => $patron_nex_l1->borrowernumber,
            biblionumber   => $item2->biblionumber,
            priority       => 2,
        }
    );

    ($status, $reserve, $all_reserves) = CheckReserves($item2);
    is($reserve->{borrowernumber}, $patron_nex_l2->borrowernumber, "Patron from other library is next checkout because item is excluded");

    $schema->storage->txn_rollback;
};
