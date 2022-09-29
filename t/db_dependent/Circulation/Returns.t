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

use Test::More tests => 7;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Members;
use C4::Circulation qw( AddReturn AddIssue LostItem );
use C4::Items;
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::Account::Lines;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Patrons;

use MARC::Record;
use MARC::Field;

# Mock userenv, used by AddIssue
my $branch;
my $manager_id;
my $context = Test::MockModule->new('C4::Context');
$context->mock(
    'userenv',
    sub {
        return {
            branch    => $branch,
            number    => $manager_id,
            firstname => "Adam",
            surname   => "Smaith"
        };
    }
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
Koha::CirculationRules->search->delete;
Koha::CirculationRules->set_rule(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rule_name    => 'issuelength',
        rule_value   => 1,
    }
);

subtest "AddReturn logging on statistics table (item-level_itypes=1)" => sub {

    plan tests => 3;

    # Set item-level item types
    t::lib::Mocks::mock_preference( "item-level_itypes", 1 );

    # Make sure logging is enabled
    t::lib::Mocks::mock_preference( "IssueLog", 1 );
    t::lib::Mocks::mock_preference( "ReturnLog", 1 );

    # Create an itemtype for biblio-level item type
    my $blevel_itemtype = $builder->build({ source => 'Itemtype' })->{ itemtype };
    # Create an itemtype for item-level item type
    my $ilevel_itemtype = $builder->build({ source => 'Itemtype' })->{ itemtype };
    # Create a branch
    $branch = $builder->build({ source => 'Branch' })->{ branchcode };
    # Create a borrower
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { branchcode => $branch }
    });
    # Look for the defined MARC field for biblio-level itemtype
    my $rs = $schema->resultset('MarcSubfieldStructure')->search({
        frameworkcode => '',
        kohafield     => 'biblioitems.itemtype'
    });
    my $tagfield    = $rs->first->tagfield;
    my $tagsubfield = $rs->first->tagsubfield;

    # Create a biblio record with biblio-level itemtype
    my $record = MARC::Record->new();
    $record->append_fields(
        MARC::Field->new($tagfield,'','', $tagsubfield => $blevel_itemtype )
    );
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );
    my $item_with_itemtype = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch,
            itype        => $ilevel_itemtype
        }
    );
    my $item_without_itemtype = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch,
        }
    )->_result->update({ itype => undef });

    AddIssue( $patron, $item_with_itemtype->barcode );
    AddReturn( $item_with_itemtype->barcode, $branch );
    # Test item-level itemtype was recorded on the 'statistics' table
    my $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_with_itemtype->itemnumber
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $ilevel_itemtype,
        "item-level itype recorded on statistics for return");
    warning_like { AddIssue( $patron, $item_without_itemtype->barcode ) }
                 [qr/^item-level_itypes set but no itemtype set for item/,
                 qr/^item-level_itypes set but no itemtype set for item/,
                 qr/^item-level_itypes set but no itemtype set for item/],
                 'Item without itemtype set raises warning on AddIssue';
    AddReturn( $item_without_itemtype->barcode, $branch );
    # Test biblio-level itemtype was recorded on the 'statistics' table
    $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_without_itemtype->itemnumber
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $blevel_itemtype,
        "biblio-level itype recorded on statistics for return as a fallback for null item-level itype");

};

subtest "AddReturn logging on statistics table (item-level_itypes=0)" => sub {

    plan tests => 2;

    # Make sure logging is enabled
    t::lib::Mocks::mock_preference( "IssueLog", 1 );
    t::lib::Mocks::mock_preference( "ReturnLog", 1 );

    # Set biblio level item types
    t::lib::Mocks::mock_preference( "item-level_itypes", 0 );

    # Create an itemtype for biblio-level item type
    my $blevel_itemtype = $builder->build({ source => 'Itemtype' })->{ itemtype };
    # Create an itemtype for item-level item type
    my $ilevel_itemtype = $builder->build({ source => 'Itemtype' })->{ itemtype };
    # Create a branch
    $branch = $builder->build({ source => 'Branch' })->{ branchcode };
    # Create a borrower
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { branchcode => $branch }
    })->{ borrowernumber };
    # Look for the defined MARC field for biblio-level itemtype
    my $rs = $schema->resultset('MarcSubfieldStructure')->search({
        frameworkcode => '',
        kohafield     => 'biblioitems.itemtype'
    });
    my $tagfield    = $rs->first->tagfield;
    my $tagsubfield = $rs->first->tagsubfield;

    # Create a biblio record with biblio-level itemtype
    my $record = MARC::Record->new();
    $record->append_fields(
        MARC::Field->new($tagfield,'','', $tagsubfield => $blevel_itemtype )
    );
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );
    my $item_with_itemtype = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch,
            itype        => $ilevel_itemtype
        }
    );
    my $item_without_itemtype = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch,
            itype        => undef
        }
    );

    AddIssue( $patron, $item_with_itemtype->barcode );
    AddReturn( $item_with_itemtype->barcode, $branch );
    # Test item-level itemtype was recorded on the 'statistics' table
    my $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_with_itemtype->itemnumber
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $blevel_itemtype,
        "biblio-level itype recorded on statistics for return");

    AddIssue( $patron, $item_without_itemtype->barcode );
    AddReturn( $item_without_itemtype->barcode, $branch );
    # Test biblio-level itemtype was recorded on the 'statistics' table
    $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_without_itemtype->itemnumber
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $blevel_itemtype,
        "biblio-level itype recorded on statistics for return");
};

subtest 'Handle ids duplication' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
    t::lib::Mocks::mock_preference( 'CalculateFinesOnReturn', 1 );
    t::lib::Mocks::mock_preference( 'finesMode', 'production' );
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                chargeperiod => 1,
                fine         => 1,
                firstremind  => 1,
            }
        }
    );

    my $itemtype = $builder->build( { source => 'Itemtype', value => { rentalcharge => 5 } } );
    my $item = $builder->build_sample_item(
        {
            itype => $itemtype->{itemtype},
        }
    );
    my $patron = $builder->build_object(
        { class => 'Koha::Patrons'}
    );

    my $original_checkout = AddIssue( $patron, $item->barcode, dt_from_string->subtract( days => 50 ) );
    my $issue_id = $original_checkout->issue_id;
    my $account_lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber, issue_id => $issue_id });
    is( $account_lines->count, 1, '1 account line should exist for this issue_id' );
    is( $account_lines->next->debit_type_code, 'RENT', 'patron has been charged the rentalcharge' );
    $account_lines->delete;

    # Create an existing entry in old_issue
    $builder->build({ source => 'OldIssue', value => { issue_id => $issue_id } });

    my $old_checkout = Koha::Old::Checkouts->find( $issue_id );

    my ($doreturn, $messages, $new_checkout, $borrower);
    warning_like {
        ( $doreturn, $messages, $new_checkout, $borrower ) =
          AddReturn( $item->barcode, undef, undef, undef, dt_from_string );
    }
    [
        qr{.*DBD::mysql::st execute failed: Duplicate entry.*},
        { carped => qr{The checkin for the following issue failed.*Duplicate ID.*} }
    ],
    'DBD should have raised an error about dup primary key';

    is( $doreturn, 0, 'Return should not have been done' );
    is( $messages->{WasReturned}, 0, 'messages should have the WasReturned flag set to 0' );
    is( $messages->{DataCorrupted}, 1, 'messages should have the DataCorrupted flag set to 1' );

    $account_lines = Koha::Account::Lines->search({ borrowernumber => $borrower->{borrowernumber}, issue_id => $issue_id });
    is( $account_lines->count, 0, 'No account lines should exist for this issue_id, patron should not have been charged' );

    is( Koha::Checkouts->find( $issue_id )->issue_id, $issue_id, 'The issues entry should not have been removed' );
};

subtest 'BlockReturnOfLostItems' => sub {
    plan tests => 4;
    my $item = $builder->build_sample_item;
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $checkout = AddIssue( $patron, $item->barcode );

    # Mark the item as lost
    $item->itemlost(1)->store;

    t::lib::Mocks::mock_preference('BlockReturnOfLostItems', 1);
    my ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    is( $doreturn, 0, "With BlockReturnOfLostItems, a checkin of a lost item should be blocked");
    is( $messages->{WasLost}, 1, "... and the WasLost flag should be set");

    $item->discard_changes;
    is( $item->itemlost, 1, "Item remains lost" );

    t::lib::Mocks::mock_preference('BlockReturnOfLostItems', 0);
    ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    is( $doreturn, 1, "Without BlockReturnOfLostItems, a checkin of a lost item should not be blocked");
};

subtest 'Checkin of an item claimed as returned should generate a message' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference('ClaimReturnedLostValue', 1);
    my $item = $builder->build_sample_item;
    my $patron = $builder->build_object({class => 'Koha::Patrons'});
    my $checkout = AddIssue( $patron, $item->barcode );

    $checkout->claim_returned({ created_by => $patron->id });

    my ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    ok( $messages->{ReturnClaims}, "ReturnClaims is in messages for return of a claimed as returned itm" );
};

subtest 'BranchTransferLimitsType' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('AutomaticItemReturn', 0);
    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'ccode');

    my $item = $builder->build_sample_item;
    my $patron = $builder->build_object({class => 'Koha::Patrons'});
    my $checkout = AddIssue( $patron, $item->barcode );
    my ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    is( $doreturn, 1, 'AddReturn should have checkin the item if BranchTransferLimitsType=ccode');

    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
    $checkout = AddIssue( $patron, $item->barcode );
    ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    is( $doreturn, 1, 'AddReturn should have checkin the item if BranchTransferLimitsType=itemtype');
};

subtest 'Backdated returns should reduce fine if needed' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( "CalculateFinesOnReturn",   0 );
    t::lib::Mocks::mock_preference( "CalculateFinesOnBackdate", 1 );

    my $biblio = $builder->build_object( { class => 'Koha::Biblios' } );
    my $item = $builder->build_sample_item;
    my $patron = $builder->build_object({class => 'Koha::Patrons'});
    my $checkout = AddIssue( $patron, $item->barcode );
    my $fine = Koha::Account::Line->new({
        issue_id => $checkout->id,
        borrowernumber => $patron->id,
        itemnumber => $item->id,
        date => dt_from_string(),
        amount => 100,
        amountoutstanding => 100,
        debit_type_code => 'OVERDUE',
        status => 'UNRETURNED',
        timestamp => dt_from_string(),
        manager_id => undef,
        interface => 'cli',
        branchcode => $patron->branchcode,
    })->store();

    my $account = $patron->account;
    is( $account->balance+0, 100, "Account balance before return is 100");

    my ( $doreturn, $messages, $issue ) = AddReturn($item->barcode, undef, undef, dt_from_string('1999-01-01') );
    is( $account->balance+0, 0, "Account balance after return is 0");

    $fine = $fine->get_from_storage;
    is( $fine, undef, "Fine was removed correctly with a backdated return" );
};

$schema->storage->txn_rollback;
