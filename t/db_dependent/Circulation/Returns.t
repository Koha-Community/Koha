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

use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio;
use C4::Circulation;
use C4::Items;
use C4::Members;
use Koha::Database;
use Koha::Account::Lines;
use Koha::DateUtils;
use Koha::Items;
use Koha::Patrons;

use MARC::Record;
use MARC::Field;

# Mock userenv, used by AddIssue
my $branch;
my $context = Test::MockModule->new('C4::Context');
$context->mock( 'userenv', sub {
    return { branch => $branch }
});

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
Koha::IssuingRules->search->delete;
my $rule = Koha::IssuingRule->new(
    {
        categorycode => '*',
        itemtype     => '*',
        branchcode   => '*',
        maxissueqty  => 99,
        issuelength  => 1,
    }
);
$rule->store();

subtest "InProcessingToShelvingCart tests" => sub {

    plan tests => 2;

    $branch = $builder->build({ source => 'Branch' })->{ branchcode };
    my $permanent_location = 'TEST';
    my $location           = 'PROC';

    # Create a biblio record with biblio-level itemtype
    my $record = MARC::Record->new();
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );
    my $built_item = $builder->build({
        source => 'Item',
        value  => {
            biblionumber  => $biblionumber,
            homebranch    => $branch,
            holdingbranch => $branch,
            location      => $location,
            permanent_location => $permanent_location
        }
    });
    my $barcode = $built_item->{ barcode };
    my $itemnumber = $built_item->{ itemnumber };
    my $item;

    t::lib::Mocks::mock_preference( "InProcessingToShelvingCart", 1 );
    AddReturn( $barcode, $branch );
    $item = GetItem( $itemnumber );
    is( $item->{location}, 'CART',
        "InProcessingToShelvingCart functions as intended" );

    $item->{location} = $location;
    ModItem( $item, undef, $itemnumber );

    t::lib::Mocks::mock_preference( "InProcessingToShelvingCart", 0 );
    AddReturn( $barcode, $branch );
    $item = GetItem( $itemnumber );
    is( $item->{location}, $permanent_location,
        "InProcessingToShelvingCart functions as intended" );
};


subtest "AddReturn logging on statistics table (item-level_itypes=1)" => sub {

    plan tests => 4;

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
    my $borrowernumber = $builder->build({
        source => 'Borrower',
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
    my $item_with_itemtype = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber     => $biblionumber,
                biblioitemnumber => $biblioitemnumber,
                homebranch       => $branch,
                holdingbranch    => $branch,
                itype            => $ilevel_itemtype
            }
        }
    );
    my $item_without_itemtype = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber     => $biblionumber,
                biblioitemnumber => $biblioitemnumber,
                homebranch       => $branch,
                holdingbranch    => $branch,
                itype            => undef
            }
        }
    );

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
    AddIssue( $borrower, $item_with_itemtype->{ barcode } );
    AddReturn( $item_with_itemtype->{ barcode }, $branch );
    # Test item-level itemtype was recorded on the 'statistics' table
    my $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_with_itemtype->{ itemnumber }
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $ilevel_itemtype,
        "item-level itype recorded on statistics for return");
    warning_like { AddIssue( $borrower, $item_without_itemtype->{ barcode } ) }
                 [qr/^item-level_itypes set but no itemtype set for item/,
                 qr/^item-level_itypes set but no itemtype set for item/],
                 'Item without itemtype set raises warning on AddIssue';
    warning_like { AddReturn( $item_without_itemtype->{ barcode }, $branch ) }
                 qr/^item-level_itypes set but no itemtype set for item/,
                 'Item without itemtype set raises warning on AddReturn';
    # Test biblio-level itemtype was recorded on the 'statistics' table
    $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_without_itemtype->{ itemnumber }
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
    my $borrowernumber = $builder->build({
        source => 'Borrower',
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
    my $item_with_itemtype = $builder->build({
        source => 'Item',
        value  => {
            biblionumber  => $biblionumber,
            biblioitemnumber => $biblioitemnumber,
            homebranch    => $branch,
            holdingbranch => $branch,
            itype         => $ilevel_itemtype
        }
    });
    my $item_without_itemtype = $builder->build({
        source => 'Item',
        value  => {
            biblionumber  => $biblionumber,
            biblioitemnumber => $biblioitemnumber,
            homebranch    => $branch,
            holdingbranch => $branch,
            itype         => undef
        }
    });

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

    AddIssue( $borrower, $item_with_itemtype->{ barcode } );
    AddReturn( $item_with_itemtype->{ barcode }, $branch );
    # Test item-level itemtype was recorded on the 'statistics' table
    my $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_with_itemtype->{ itemnumber }
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $blevel_itemtype,
        "biblio-level itype recorded on statistics for return");

    AddIssue( $borrower, $item_without_itemtype->{ barcode } );
    AddReturn( $item_without_itemtype->{ barcode }, $branch );
    # Test biblio-level itemtype was recorded on the 'statistics' table
    $stat = $schema->resultset('Statistic')->search({
        branch     => $branch,
        type       => 'return',
        itemnumber => $item_without_itemtype->{ itemnumber }
    }, { order_by => { -asc => 'datetime' } })->next();

    is( $stat->itemtype, $blevel_itemtype,
        "biblio-level itype recorded on statistics for return");
};

subtest 'Handle ids duplication' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
    t::lib::Mocks::mock_preference( 'CalculateFinesOnReturn', 1 );
    t::lib::Mocks::mock_preference( 'finesMode', 'production' );
    Koha::IssuingRules->search->update({ chargeperiod => 1, fine => 1, firstremind => 1, });

    my $biblio = $builder->build( { source => 'Biblio' } );
    my $itemtype = $builder->build( { source => 'Itemtype', value => { rentalcharge => 5 } } );
    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber => $biblio->{biblionumber},
                notforloan => 0,
                itemlost   => 0,
                withdrawn  => 0,
                itype      => $itemtype->{itemtype},
            }
        }
    );
    my $patron = $builder->build({source => 'Borrower'});
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );

    my $original_checkout = AddIssue( $patron->unblessed, $item->{barcode}, dt_from_string->subtract( days => 50 ) );
    my $issue_id = $original_checkout->issue_id;
    my $account_lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber, issue_id => $issue_id });
    is( $account_lines->count, 1, '1 account line should exist for this issue_id' );
    is( $account_lines->next->description, 'Rental', 'patron has been charged the rentalcharge' );
    $account_lines->delete;

    # Create an existing entry in old_issue
    $builder->build({ source => 'OldIssue', value => { issue_id => $issue_id } });

    my $old_checkout = Koha::Old::Checkouts->find( $issue_id );

    my ($doreturn, $messages, $new_checkout, $borrower);
    warning_like {
        ( $doreturn, $messages, $new_checkout, $borrower ) =
          AddReturn( $item->{barcode}, undef, undef, undef, dt_from_string );
    }
    [
        qr{.*DBD::mysql::st execute failed: Duplicate entry.*},
        { carped => qr{The checkin for the following issue failed.*Duplicate ID.*} }
    ],
    'DBD should have raised an error about dup primary key';

    is( $doreturn, 0, 'Return should not have been done' );
    is( $messages->{WasReturned}, 0, 'messages should have the WasReturned flag set to 0' );
    is( $messages->{DataCorrupted}, 1, 'messages should have the DataCorrupted flag set to 1' );

    $account_lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber, issue_id => $issue_id });
    is( $account_lines->count, 0, 'No account lines should exist for this issue_id, patron should not have been charged' );

    is( Koha::Checkouts->find( $issue_id )->issue_id, $issue_id, 'The issues entry should not have been removed' );
};

subtest 'BlockReturnOfLostItems' => sub {
    plan tests => 3;
    my $biblio = $builder->build_object( { class => 'Koha::Biblios' } );
    my $item = $builder->build_object(
        {
            class  => 'Koha::Items',
            value  => {
                biblionumber => $biblio->biblionumber,
                notforloan => 0,
                itemlost   => 0,
                withdrawn  => 0,
        }
    }
    );
    my $patron = $builder->build_object({class => 'Koha::Patrons'});
    my $checkout = AddIssue( $patron->unblessed, $item->barcode );

    # Mark the item as lost
    ModItem({itemlost => 1}, $biblio->biblionumber, $item->itemnumber);

    t::lib::Mocks::mock_preference('BlockReturnOfLostItems', 1);
    my ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    is( $doreturn, 0, "With BlockReturnOfLostItems, a checkin of a lost item should be blocked");
    is( $messages->{WasLost}, 1, "... and the WasLost flag should be set");

    t::lib::Mocks::mock_preference('BlockReturnOfLostItems', 0);
    ( $doreturn, $messages, $issue ) = AddReturn($item->barcode);
    is( $doreturn, 1, "Without BlockReturnOfLostItems, a checkin of a lost item should not be blocked");
};
