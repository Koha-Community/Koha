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

use Test::More tests => 4;
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

    my $borrower = GetMember( borrowernumber => $borrowernumber );
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
                 qr/^item-level_itypes set but no itemtype set for item/,
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

    # Set item-level item types
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
            homebranch    => $branch,
            holdingbranch => $branch,
            itype         => $ilevel_itemtype
        }
    });
    my $item_without_itemtype = $builder->build({
        source => 'Item',
        value  => {
            biblionumber  => $biblionumber,
            homebranch    => $branch,
            holdingbranch => $branch,
            itype         => undef
        }
    });

    my $borrower = GetMember( borrowernumber => $borrowernumber );

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
    plan tests => 4;

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
    $builder->build({ source => 'OldIssue', value => { issue_id => $original_checkout->issue_id } });
    my $old_checkout = Koha::Old::Checkouts->find( $original_checkout->issue_id );

    AddRenewal( $patron->borrowernumber, $item->{itemnumber} );

    my ($doreturn, $messages, $new_checkout, $borrower) = AddReturn( $item->{barcode}, undef, undef, undef, dt_from_string );

    my $account_lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber, issue_id => $original_checkout->issue_id });
    is( $account_lines->count, 0, 'No account lines should exist on old issue_id' );

    $account_lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber, issue_id => $new_checkout->{issue_id} });
    is( $account_lines->count, 2, 'Two account lines should exist on new issue_id' );

    isnt( $original_checkout->issue_id, $new_checkout->{issue_id}, 'AddReturn should return the issue with the new issue_id' );
    isnt( $old_checkout->itemnumber, $item->{itemnumber}, 'If an item is checked-in, it should be moved to old_issues even if the issue_id already existed in the table' );
};

1;
