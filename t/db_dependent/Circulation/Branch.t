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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Circulation qw( AddIssue AddReturn GetBranchBorrowerCircRule GetBranchItemRule );
use C4::Items       qw( ModItemTransfer );
use C4::Biblio      qw( AddBiblio );
use C4::Context;
use Koha::CirculationRules;

use Koha::Patrons;

use Test::NoWarnings;
use Test::More tests => 19;
use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    use_ok( 'C4::Circulation', qw( AddIssue AddReturn GetBranchBorrowerCircRule GetBranchItemRule ) );
}

can_ok(
    'C4::Circulation', qw(
        AddIssue
        AddReturn
        GetBranchBorrowerCircRule
        GetBranchItemRule
    )
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $query;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM clubs|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM itemtypes|);
$dbh->do(q|DELETE FROM circulation_rules|);

my $builder = t::lib::TestBuilder->new();

# Add branch
my $samplebranch1 = $builder->build( { source => 'Branch' } );
my $samplebranch2 = $builder->build( { source => 'Branch' } );

# Add itemtypes
my $no_circ_itemtype = $builder->build(
    {
        source => 'Itemtype',
        value  => {
            rentalcharge => '0',
            notforloan   => 0
        }
    }
);
my $sampleitemtype1 = $builder->build(
    {
        source => 'Itemtype',
        value  => {
            rentalcharge => '10.0',
            notforloan   => 1
        }
    }
);
my $sampleitemtype2 = $builder->build(
    {
        source => 'Itemtype',
        value  => {
            rentalcharge => '5.0',
            notforloan   => 0
        }
    }
);

# Add Category
my $samplecat = $builder->build(
    {
        source => 'Category',
        value  => { hidelostitems => 0 }
    }
);

#Add biblio and item
my $record = MARC::Record->new();
$record->append_fields( MARC::Field->new( '952', '0', '0', a => $samplebranch1->{branchcode} ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' );

# item 1 has home branch and holding branch samplebranch1
my $item_id1 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 'barcode_1',
        itemcallnumber => 'callnumber1',
        homebranch     => $samplebranch1->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode},
        itype          => $no_circ_itemtype->{itemtype}
    }
)->store->itemnumber;

# item 2 has holding branch samplebranch2
my $item_id2 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 'barcode_2',
        itemcallnumber => 'callnumber2',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode},
        itype          => $no_circ_itemtype->{itemtype}
    },
)->store->itemnumber;

# item 3 has item type sampleitemtype2 with noreturn policy
my $item_id3 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 'barcode_3',
        itemcallnumber => 'callnumber3',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch2->{branchcode},
        itype          => $sampleitemtype2->{itemtype}
    }
)->store->itemnumber;

#Add borrower
my $borrower_id1 = Koha::Patron->new(
    {
        firstname    => 'firstname1',
        surname      => 'surname1 ',
        categorycode => $samplecat->{categorycode},
        branchcode   => $samplebranch1->{branchcode},
    }
)->store->borrowernumber;

is_deeply(
    GetBranchBorrowerCircRule(),
    { patron_maxissueqty => undef, patron_maxonsiteissueqty => undef },
    "Without parameter, GetBranchBorrower returns undef (unilimited) for patron_maxissueqty and patron_maxonsiteissueqty if no rules defined"
);

Koha::CirculationRules->set_rules(
    {
        branchcode   => $samplebranch1->{branchcode},
        categorycode => $samplecat->{categorycode},
        rules        => {
            patron_maxissueqty       => 5,
            patron_maxonsiteissueqty => 6,
        }
    }
);

Koha::CirculationRules->set_rules(
    {
        branchcode   => $samplebranch2->{branchcode},
        categorycode => undef,
        rules        => {
            patron_maxissueqty       => 3,
            patron_maxonsiteissueqty => 2,
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        branchcode => $samplebranch2->{branchcode},
        itemtype   => undef,
        rules      => {
            holdallowed  => 'from_home_library',
            returnbranch => 'holdingbranch',
        }
    }
);

Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        categorycode => undef,
        rules        => {
            patron_maxissueqty       => 4,
            patron_maxonsiteissueqty => 5,
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        branchcode => undef,
        itemtype   => undef,
        rules      => {
            holdallowed  => 'from_local_hold_group',
            returnbranch => 'homebranch',
        }
    }
);

Koha::CirculationRules->set_rules(
    {
        branchcode => $samplebranch1->{branchcode},
        itemtype   => $sampleitemtype1->{itemtype},
        rules      => {
            holdallowed  => 'invalid_value',
            returnbranch => 'homebranch',
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        branchcode => $samplebranch2->{branchcode},
        itemtype   => $sampleitemtype1->{itemtype},
        rules      => {
            holdallowed  => 'invalid_value',
            returnbranch => 'holdingbranch',
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        branchcode => $samplebranch2->{branchcode},
        itemtype   => $sampleitemtype2->{itemtype},
        rules      => {
            holdallowed  => 'invalid_value',
            returnbranch => 'noreturn',
        }
    }
);

#Test GetBranchBorrowerCircRule
is_deeply(
    GetBranchBorrowerCircRule(),
    { patron_maxissueqty => 4, patron_maxonsiteissueqty => 5 },
    "Without parameter, GetBranchBorrower returns the patron_maxissueqty and patron_maxonsiteissueqty of default_circ_rules"
);
is_deeply(
    GetBranchBorrowerCircRule( $samplebranch2->{branchcode} ),
    { patron_maxissueqty => 3, patron_maxonsiteissueqty => 2 },
    "Without only the branchcode specified, GetBranchBorrower returns the patron_maxissueqty and patron_maxonsiteissueqty corresponding"
);
is_deeply(
    GetBranchBorrowerCircRule(
        $samplebranch1->{branchcode},
        $samplecat->{categorycode}
    ),
    { patron_maxissueqty => 5, patron_maxonsiteissueqty => 6 },
    "GetBranchBorrower returns the patron_maxissueqty and patron_maxonsiteissueqty of the branch1 and the category1"
);
is_deeply(
    GetBranchBorrowerCircRule( -1, -1 ),
    { patron_maxissueqty => 4, patron_maxonsiteissueqty => 5 },
    "GetBranchBorrower with wrong parameters returns the patron_maxissueqty and patron_maxonsiteissueqty of default_circ_rules"
);

#Test GetBranchItemRule
my @lazy_any = ( 'hold_fulfillment_policy' => 'any' );
is_deeply(
    GetBranchItemRule(
        $samplebranch1->{branchcode},
        $sampleitemtype1->{itemtype},
    ),
    { holdallowed => 'invalid_value', @lazy_any },
    "GetBranchitem returns holdallowed and return branch"
);
is_deeply(
    GetBranchItemRule(),
    { holdallowed => 'from_local_hold_group', @lazy_any },
    "Without parameters GetBranchItemRule returns the values in default_circ_rules"
);
is_deeply(
    GetBranchItemRule( $samplebranch2->{branchcode} ),
    { holdallowed => 'from_home_library', @lazy_any },
    "With only a branchcode GetBranchItemRule returns values in default_branch_circ_rules"
);
is_deeply(
    GetBranchItemRule( -1, -1 ),
    { holdallowed => 'from_local_hold_group', @lazy_any },
    "With only one parametern GetBranchItemRule returns default values"
);

# Test return policies
t::lib::Mocks::mock_preference( 'AutomaticItemReturn', '0' );

# item1 returned at branch2 should trigger transfer to homebranch
$query = "INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id1, $samplebranch1->{branchcode} );

t::lib::Mocks::mock_preference( 'CataloguingLog', 1 );
t::lib::Mocks::mock_userenv( { branchcode => $samplebranch2->{branchcode} } );

my $log_count_before = $schema->resultset('ActionLog')->search( { module => 'CATALOGUING' } )->count();
my ( $doreturn, $messages, $iteminformation, $borrower ) = AddReturn(
    'barcode_1',
    $samplebranch2->{branchcode}
);
is(
    $messages->{NeedsTransfer}, $samplebranch1->{branchcode},
    "AddReturn respects default return policy - return to homebranch"
);
my $log_count_after = $schema->resultset('ActionLog')->search( { module => 'CATALOGUING' } )->count();
is( $log_count_before, $log_count_after, "Update to holdingbranch is not logged" );

# item2 returned at branch2 should trigger transfer to holding branch
$query = "INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id2, $samplebranch2->{branchcode} );
( $doreturn, $messages, $iteminformation, $borrower ) = AddReturn(
    'barcode_2',
    $samplebranch2->{branchcode}
);
is(
    $messages->{NeedsTransfer}, $samplebranch1->{branchcode},
    "AddReturn respects branch return policy - item2->homebranch policy = 'holdingbranch'"
);

# Generate the transfer from above
ModItemTransfer( $item_id2, $samplebranch2->{branchcode}, $samplebranch1->{branchcode}, "ReturnToHolding" );

# Fulfill it
( $doreturn, $messages, $iteminformation, $borrower ) = AddReturn( 'barcode_2', $samplebranch1->{branchcode} );
is(
    $messages->{NeedsTransfer}, undef,
    "AddReturn does not generate a new transfer for return policy when resolving an existing non-Reserve transfer"
);

# Generate a hold caused transfer which doesn't have a hold i.e. is the hold is cancelled
ModItemTransfer( $item_id2, $samplebranch2->{branchcode}, $samplebranch1->{branchcode}, "Reserve" );

# Fulfill it
( $doreturn, $messages, $iteminformation, $borrower ) = AddReturn( 'barcode_2', $samplebranch1->{branchcode} );
is(
    $messages->{NeedsTransfer}, $samplebranch2->{branchcode},
    "AddReturn generates a new transfer for hold transfer if the hold was cancelled"
);

# item3 should not trigger transfer - floating collection
$query = "INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id3, $samplebranch1->{branchcode} );
t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
( $doreturn, $messages, $iteminformation, $borrower ) = AddReturn(
    'barcode_3',
    $samplebranch1->{branchcode}
);
is( $messages->{NeedsTransfer}, undef, "AddReturn respects branch item return policy - noreturn" );
t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );

$schema->storage->txn_rollback;

subtest "GetBranchItemRule() tests" => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    $dbh->do('DELETE FROM circulation_rules');

    my $homebranch    = $builder->build( { source => 'Branch' } )->{branchcode};
    my $holdingbranch = $builder->build( { source => 'Branch' } )->{branchcode};
    my $checkinbranch = $builder->build( { source => 'Branch' } )->{branchcode};

    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv(
        {
            patron     => $manager,
            branchcode => $checkinbranch,
        }
    );

    my $biblio = $builder->build_sample_biblio;
    my $item   = Koha::Item->new(
        {
            biblionumber  => $biblio->id,
            homebranch    => $homebranch,
            holdingbranch => $holdingbranch,
            itype         => $sampleitemtype1->{itemtype}
        }
    )->store;

    Koha::CirculationRules->set_rule(
        {
            branchcode => $homebranch,
            itemtype   => undef,
            rule_name  => 'returnbranch',
            rule_value => 'homebranch',
        }
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode => $holdingbranch,
            itemtype   => undef,
            rule_name  => 'returnbranch',
            rule_value => 'holdingbranch',
        }
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode => $checkinbranch,
            itemtype   => undef,
            rule_name  => 'returnbranch',
            rule_value => 'noreturn',
        }
    );

    t::lib::Mocks::mock_preference( 'CircControlReturnsBranch', 'ItemHomeLibrary' );
    is( Koha::CirculationRules->get_return_branch_policy($item), 'homebranch' );

    t::lib::Mocks::mock_preference( 'CircControlReturnsBranch', 'ItemHoldingLibrary' );
    is( Koha::CirculationRules->get_return_branch_policy($item), 'holdingbranch' );

    t::lib::Mocks::mock_preference( 'CircControlReturnsBranch', 'CheckInLibrary' );
    is( Koha::CirculationRules->get_return_branch_policy($item), 'noreturn' );

    $schema->storage->txn_rollback;
};
