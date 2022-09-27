#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use Koha::CirculationRules;

use Test::More tests => 11;

use t::lib::TestBuilder;
use t::lib::Mocks;
use Koha::Holds;

BEGIN {
    use_ok('C4::Reserves', qw( AddReserve CheckReserves ));
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
my $library3 = $builder->build({
    source => 'Branch',
});
my $itemtype = $builder->build_sample_item->itype;

my $bib_title = "Test Title";

my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library1->{branchcode},
    }
});

# Test hold_fulfillment_policy
my $borrowernumber = $borrower->{borrowernumber};
my $library_A = $library1->{branchcode};
my $library_B = $library2->{branchcode};
my $library_C = $library3->{branchcode};
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM circulation_rules");

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$bib_title', '2011-02-01')");

my $biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$bib_title'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$itemtype')");

my $biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_B', 0, 0, 0, 0, NULL, '$itemtype')
");

my $item = Koha::Items->find({ biblionumber => $biblionumber });

# With hold_fulfillment_policy = homebranch, hold should only be picked up if pickup branch = homebranch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'homebranch',
        }
    }
);

# Home branch matches pickup branch
my $reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
my ( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Hold where pickup branch matches home branch targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is($status, q{}, "Hold where pickup ne home, pickup eq home not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, q{}, "Hold where pickup ne home, pickup ne holding not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# With hold_fulfillment_policy = holdingbranch, hold should only be picked up if pickup branch = holdingbranch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'holdingbranch',
        }
    }
);

# Home branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, q{}, "Hold where pickup eq home, pickup ne holding not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Hold where pickup ne home, pickup eq holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, q{}, "Hold where pickup ne home, pickup ne holding not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# With hold_fulfillment_policy = any, hold should be pikcup up reguardless of matching home or holding branch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'any',
        }
    }
);

# Home branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Hold where pickup eq home, pickup ne holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Hold where pickup ne home, pickup eq holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Hold where pickup ne home, pickup ne holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Test enforement of branch transfer limits
t::lib::Mocks::mock_preference( 'UseBranchTransferLimits',  '1' );
t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );
Koha::Holds->search()->delete();
my $limit = Koha::Item::Transfer::Limit->new(
    {
        toBranch   => $library_C,
        fromBranch => $item->holdingbranch,
        itemtype   => $item->effective_itemtype,
    }
)->store();
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1
    }
);
($status) = CheckReserves($item);
is( $status, '',  "No hold where branch transfer is not allowed" );
Koha::Holds->find($reserve_id)->cancel;
