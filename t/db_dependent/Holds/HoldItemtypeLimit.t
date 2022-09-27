#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use Koha::CirculationRules;

use Test::More tests => 4;

use t::lib::TestBuilder;

use Koha::Holds;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves', qw( AddReserve CheckReserves ));
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => 'Branch',
});

my $bib_title = "Test Title";


my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library->{branchcode},
    }
});

my $itemtype1 = $builder->build({
    source => 'Itemtype',
    value => {
        notforloan => 0
    }
});

my $itemtype2 = $builder->build({
    source => 'Itemtype',
    value => {
        notforloan => 0
    }
});


# Test hold_fulfillment_policy
my $right_itemtype = $itemtype1->{itemtype};
my $wrong_itemtype = $itemtype2->{itemtype};
my $borrowernumber = $borrower->{borrowernumber};
my $branchcode = $library->{branchcode};
$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM issues");
$dbh->do("DELETE FROM items");
$dbh->do("DELETE FROM biblio");
$dbh->do("DELETE FROM biblioitems");
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$bib_title', '2011-02-01')");

my $biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$bib_title'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$right_itemtype')");

my $biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$branchcode', '$branchcode', 0, 0, 0, 0, NULL, '$right_itemtype')
");

my $item = Koha::Items->find({ biblionumber => $biblionumber });

$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            holdallowed             => 2,
            hold_fulfillment_policy => 'any',
        }
    }
);

# Itemtypes match
my $reserve_id = AddReserve(
    {
        branchcode     => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
        itemtype       => $right_itemtype,
    }
);
my ( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Hold where itemtype matches item's itemtype targed" );
Koha::Holds->find( $reserve_id )->cancel;

# Itemtypes don't match
$reserve_id = AddReserve(
    {
        branchcode     => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
        itemtype       => $wrong_itemtype,
    }
);

( $status ) = CheckReserves($item);
is($status, q{}, "Hold where itemtype does not match item's itemtype not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# No itemtype set
$reserve_id = AddReserve(
    {
        branchcode     => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
( $status ) = CheckReserves($item);
is( $status, 'Reserved', "Item targeted with no hold itemtype set" );
Koha::Holds->find( $reserve_id )->cancel;

# Cleanup
$schema->storage->txn_rollback;
