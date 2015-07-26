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

use Test::More tests => 3;
use Test::MockModule;
use t::lib::TestBuilder;

use t::lib::Mocks;
use C4::Biblio;
use C4::Circulation;
use C4::Items;
use C4::ItemType;
use C4::Members;
use Koha::Database;
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

    C4::Context->set_preference( "InProcessingToShelvingCart", 1 );
    AddReturn( $barcode, $branch );
    $item = GetItem( $itemnumber );
    is( $item->{location}, 'CART',
        "InProcessingToShelvingCart functions as intended" );

    $item->{location} = $location;
    ModItem( $item, undef, $itemnumber );

    C4::Context->set_preference( "InProcessingToShelvingCart", 0 );
    AddReturn( $barcode, $branch );
    $item = GetItem( $itemnumber );
    is( $item->{location}, $permanent_location,
        "InProcessingToShelvingCart functions as intended" );
};


subtest "AddReturn logging on statistics table (item-level_itypes=1)" => sub {

    plan tests => 2;

    # Set item-level item types
    C4::Context->set_preference( "item-level_itypes", 1 );

    # Make sure logging is enabled
    C4::Context->set_preference( "IssueLog", 1 );
    C4::Context->set_preference( "ReturnLog", 1 );

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

    is( $stat->itemtype, $ilevel_itemtype,
        "item-level itype recorded on statistics for return");

    AddIssue( $borrower, $item_without_itemtype->{ barcode } );
    AddReturn( $item_without_itemtype->{ barcode }, $branch );
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
    C4::Context->set_preference( "IssueLog", 1 );
    C4::Context->set_preference( "ReturnLog", 1 );

    # Set item-level item types
    C4::Context->set_preference( "item-level_itypes", 0 );

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

1;
