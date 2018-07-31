#!/usr/bin/perl

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

use C4::Circulation;
use C4::Items;
use C4::Biblio;
use C4::Context;

use Koha::Patrons;

use Test::More tests => 14;
use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Circulation');
}

can_ok( 'C4::Circulation', qw(
    AddIssue
    AddReturn
    GetBranchBorrowerCircRule
    GetBranchItemRule
    )
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM clubs|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM itemtypes|);
$dbh->do(q|DELETE FROM branch_item_rules|);
$dbh->do(q|DELETE FROM branch_borrower_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_circ_rules|);
$dbh->do(q|DELETE FROM default_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_item_rules|);

my $builder = t::lib::TestBuilder->new();

# Add branch
my $samplebranch1 = $builder->build({ source => 'Branch' });
my $samplebranch2 = $builder->build({ source => 'Branch' });
# Add itemtypes
my $no_circ_itemtype = $builder->build({
    source => 'Itemtype',
    value => {
        rentalcharge => '0',
        notforloan   => 0
    }
});
my $sampleitemtype1 = $builder->build({
    source => 'Itemtype',
    value => {
        rentalcharge => '10.0',
        notforloan   => 1
    }
});
my $sampleitemtype2 = $builder->build({
    source => 'Itemtype',
    value => {
        rentalcharge => '5.0',
        notforloan   => 0
    }
});
# Add Category
my $samplecat     = $builder->build({
    source => 'Category',
    value => {
        hidelostitems => 0
    }
});

#Add biblio and item
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => $samplebranch1->{branchcode} ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' );

# item 1 has home branch and holding branch samplebranch1
my @sampleitem1 = C4::Items::AddItem(
    {
        barcode        => 'barcode_1',
        itemcallnumber => 'callnumber1',
        homebranch     => $samplebranch1->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode},
        itype          => $no_circ_itemtype->{ itemtype }
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];

# item 2 has holding branch samplebranch2
my @sampleitem2 = C4::Items::AddItem(
    {
        barcode        => 'barcode_2',
        itemcallnumber => 'callnumber2',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode},
        itype          => $no_circ_itemtype->{ itemtype }
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];

# item 3 has item type sampleitemtype2 with noreturn policy
my @sampleitem3 = C4::Items::AddItem(
    {
        barcode        => 'barcode_3',
        itemcallnumber => 'callnumber3',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch2->{branchcode},
        itype          => $sampleitemtype2->{itemtype}
    },
    $biblionumber
);
my $item_id3 = $sampleitem3[2];

#Add borrower
my $borrower_id1 = Koha::Patron->new({
    firstname    => 'firstname1',
    surname      => 'surname1 ',
    categorycode => $samplecat->{categorycode},
    branchcode   => $samplebranch1->{branchcode},
})->store->borrowernumber;

is_deeply(
    GetBranchBorrowerCircRule(),
    { maxissueqty => undef, maxonsiteissueqty => undef },
"Without parameter, GetBranchBorrower returns undef (unilimited) for maxissueqty and maxonsiteissueqty if no rules defined"
);

my $query = q|
    INSERT INTO branch_borrower_circ_rules
    (branchcode, categorycode, maxissueqty, maxonsiteissueqty)
    VALUES( ?, ?, ?, ? )
|;

$dbh->do(
    $query, {},
    $samplebranch1->{branchcode},
    $samplecat->{categorycode}, 5, 6
);

$query = q|
    INSERT INTO default_branch_circ_rules
    (branchcode, maxissueqty, maxonsiteissueqty, holdallowed, returnbranch)
    VALUES( ?, ?, ?, ?, ? )
|;
$dbh->do( $query, {}, $samplebranch2->{branchcode},
    3, 2, 1, 'holdingbranch' );
$query = q|
    INSERT INTO default_circ_rules
    (singleton, maxissueqty, maxonsiteissueqty, holdallowed, returnbranch)
    VALUES( ?, ?, ?, ?, ? )
|;
$dbh->do( $query, {}, 'singleton', 4, 5, 3, 'homebranch' );

$query =
"INSERT INTO branch_item_rules (branchcode,itemtype,holdallowed,returnbranch) VALUES( ?,?,?,?)";
my $sth = $dbh->prepare($query);
$sth->execute(
    $samplebranch1->{branchcode},
    $sampleitemtype1->{itemtype},
    5, 'homebranch'
);
$sth->execute(
    $samplebranch2->{branchcode},
    $sampleitemtype1->{itemtype},
    5, 'holdingbranch'
);
$sth->execute(
    $samplebranch2->{branchcode},
    $sampleitemtype2->{itemtype},
    5, 'noreturn'
);

#Test GetBranchBorrowerCircRule
is_deeply(
    GetBranchBorrowerCircRule(),
    { maxissueqty => 4, maxonsiteissueqty => 5 },
"Without parameter, GetBranchBorrower returns the maxissueqty and maxonsiteissueqty of default_circ_rules"
);
is_deeply(
    GetBranchBorrowerCircRule( $samplebranch2->{branchcode} ),
    { maxissueqty => 3, maxonsiteissueqty => 2 },
"Without only the branchcode specified, GetBranchBorrower returns the maxissueqty and maxonsiteissueqty corresponding"
);
is_deeply(
    GetBranchBorrowerCircRule(
        $samplebranch1->{branchcode},
        $samplecat->{categorycode}
    ),
    { maxissueqty => 5, maxonsiteissueqty => 6 },
    "GetBranchBorrower returns the maxissueqty and maxonsiteissueqty of the branch1 and the category1"
);
is_deeply(
    GetBranchBorrowerCircRule( -1, -1 ),
    { maxissueqty => 4, maxonsiteissueqty => 5 },
"GetBranchBorrower with wrong parameters returns the maxissueqty and maxonsiteissueqty of default_circ_rules"
);

#Test GetBranchItemRule
my @lazy_any = ( 'hold_fulfillment_policy' => 'any' );
is_deeply(
    GetBranchItemRule(
        $samplebranch1->{branchcode},
        $sampleitemtype1->{itemtype},
    ),
    { returnbranch => 'homebranch', holdallowed => 5, @lazy_any },
    "GetBranchitem returns holdallowed and return branch"
);
is_deeply(
    GetBranchItemRule(),
    { returnbranch => 'homebranch', holdallowed => 3, @lazy_any },
"Without parameters GetBranchItemRule returns the values in default_circ_rules"
);
is_deeply(
    GetBranchItemRule( $samplebranch2->{branchcode} ),
    { returnbranch => 'holdingbranch', holdallowed => 1, @lazy_any },
"With only a branchcode GetBranchItemRule returns values in default_branch_circ_rules"
);
is_deeply(
    GetBranchItemRule( -1, -1 ),
    { returnbranch => 'homebranch', holdallowed => 3, @lazy_any },
    "With only one parametern GetBranchItemRule returns default values"
);

# Test return policies
t::lib::Mocks::mock_preference('AutomaticItemReturn','0');

# item1 returned at branch2 should trigger transfer to homebranch
$query =
"INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id1, $samplebranch1->{branchcode} );

my ($doreturn, $messages, $iteminformation, $borrower) = AddReturn('barcode_1',
    $samplebranch2->{branchcode});
is( $messages->{NeedsTransfer}, $samplebranch1->{branchcode}, "AddReturn respects default return policy - return to homebranch" );

# item2 returned at branch2 should trigger transfer to holding branch
$query =
"INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id2, $samplebranch2->{branchcode} );
($doreturn, $messages, $iteminformation, $borrower) = AddReturn('barcode_2',
    $samplebranch2->{branchcode});
is( $messages->{NeedsTransfer}, $samplebranch1->{branchcode}, "AddReturn respects branch return policy - item2->homebranch policy = 'holdingbranch'" );

# item3 should not trigger transfer - floating collection
$query =
"INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id3, $samplebranch1->{branchcode} );
t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
($doreturn, $messages, $iteminformation, $borrower) = AddReturn('barcode_3',
    $samplebranch1->{branchcode});
is($messages->{NeedsTransfer},undef,"AddReturn respects branch item return policy - noreturn");
t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );

$schema->storage->txn_rollback;

