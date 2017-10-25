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
use C4::Biblio;
use C4::Context;
use C4::Items;
use C4::Circulation;
use Koha::Database;
use Koha::DateUtils;
use DateTime::Duration;
use Koha::Item::Transfers;

use t::lib::TestBuilder;

use Test::More tests => 24;
use Test::Deep;

BEGIN {
    use_ok('C4::Circulation');
}
can_ok(
    'C4::Circulation',
    qw(
      CreateBranchTransferLimit
      DeleteBranchTransferLimits
      DeleteTransfer
      GetTransfers
      GetTransfersFromTo
      )
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM branch_transfer_limits|);
$dbh->do(q|DELETE FROM branchtransfers|);

## Create sample datas
# Add branches
my $branchcode_1 = $builder->build( { source => 'Branch', } )->{branchcode};
my $branchcode_2 = $builder->build( { source => 'Branch', } )->{branchcode};
# Add itemtype
my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};

#Add biblio and items
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => $branchcode_1 ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '', );

my @sampleitem1 = C4::Items::AddItem(
    {   barcode        => 1,
        itemcallnumber => 'callnumber1',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        itype          => $itemtype
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];
my @sampleitem2 = C4::Items::AddItem(
    {   barcode        => 2,
        itemcallnumber => 'callnumber2',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        itype          => $itemtype
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];

#Add transfers
ModItemTransfer(
    $item_id1,
    $branchcode_1,
    $branchcode_2
);
ModItemTransfer(
    $item_id2,
    $branchcode_1,
    $branchcode_2
);

#Begin Tests
#Test CreateBranchTransferLimit
is(
    CreateBranchTransferLimit(
        $branchcode_2,
        $branchcode_1, 'CODE'
    ),
    1,
    "A Branch TransferLimit has been added"
);
is(CreateBranchTransferLimit(),undef,
    "Without parameters CreateBranchTransferLimit returns undef");
is(CreateBranchTransferLimit($branchcode_2),undef,
    "With only tobranch CreateBranchTransferLimit returns undef");
is(CreateBranchTransferLimit(undef,$branchcode_2),undef,
    "With only frombranch CreateBranchTransferLimit returns undef");
#FIXME: Currently, we can add a transferlimit even to nonexistent branches because in the database,
#branch_transfer_limits.toBranch and branch_transfer_limits.fromBranch aren't foreign keys
#is(CreateBranchTransferLimit(-1,-1,'CODE'),0,"With wrong CreateBranchTransferLimit returns 0 - No transfertlimit added");

#Test GetTransfers
my @transfers = GetTransfers($item_id1);
cmp_deeply(
    \@transfers,
    [ re('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'), $branchcode_1, $branchcode_2, re('[0-9]*') ],
    "Transfers of the item1"
);    #NOTE: Only the first transfer is returned
@transfers = GetTransfers;
is_deeply( \@transfers, [],
    "GetTransfers without params returns an empty array" );
@transfers = GetTransfers(-1);
is_deeply( \@transfers, [],
    "GetTransfers with a wrong item id returns an empty array" );

#Test GetTransfersFromTo
my @transferfrom1to2 = GetTransfersFromTo( $branchcode_1,
    $branchcode_2 );
cmp_deeply(
    \@transferfrom1to2,
    [
        {
            branchtransfer_id => re('[0-9]*'),
            itemnumber        => $item_id1,
            datesent          => re('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'),
            frombranch        => $branchcode_1
        },
        {
            branchtransfer_id => re('[0-9]*'),
            itemnumber        => $item_id2,
            datesent          => re('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'),
            frombranch        => $branchcode_1
        }
    ],
    "Item1 and Item2 has been transferred from branch1 to branch2"
);
my @transferto = GetTransfersFromTo( undef, $branchcode_2 );
is_deeply( \@transferto, [],
    "GetTransfersfromTo without frombranch returns an empty array" );
my @transferfrom = GetTransfersFromTo( $branchcode_1 );
is_deeply( \@transferfrom, [],
    "GetTransfersfromTo without tobranch returns an empty array" );
@transferfrom = GetTransfersFromTo();
is_deeply( \@transferfrom, [],
    "GetTransfersfromTo without params returns an empty array" );

#Test DeleteBranchTransferLimits
is(
    C4::Circulation::DeleteBranchTransferLimits( $branchcode_1 ),
    1,
    "A Branch TransferLimit has been deleted"
);
is(C4::Circulation::DeleteBranchTransferLimits(),undef,"Without parameters DeleteBranchTransferLimit returns undef");
is(C4::Circulation::DeleteBranchTransferLimits('B'),'0E0',"With a wrong id DeleteBranchTransferLimit returns 0E0");

#Test DeleteTransfer
is( C4::Circulation::DeleteTransfer($item_id1),
    1, "A the item1's transfer has been deleted" );
is(C4::Circulation::DeleteTransfer(),undef,"Without itemid DeleteTransfer returns undef");
is(C4::Circulation::DeleteTransfer(-1),'0E0',"with a wrong itemid DeleteTranfer returns 0E0");

#Test TransferSlip
is( C4::Circulation::TransferSlip($branchcode_1, undef, 5, $branchcode_2),
    undef, "No tranferslip if invalid or undef itemnumber or barcode" );
is( C4::Circulation::TransferSlip($branchcode_1, $item_id1, 1, $branchcode_2)->{'code'},
    'TRANSFERSLIP', "Get a transferslip on valid itemnumber and/or barcode" );
cmp_deeply(
    C4::Circulation::TransferSlip($branchcode_1, $item_id1, undef, $branchcode_2),
    C4::Circulation::TransferSlip($branchcode_1, undef, 1, $branchcode_2),
    "Barcode and itemnumber for same item both generate same TransferSlip"
    );

$dbh->do("DELETE FROM branchtransfers");
ModItemTransfer(
    $item_id1,
    $branchcode_1,
    $branchcode_2
);
my $transfer = Koha::Item::Transfers->search()->next();
ModItemTransfer(
    $item_id1,
    $branchcode_1,
    $branchcode_2
);
$transfer->{_result}->discard_changes;
ok( $transfer->datearrived, 'Date arrived is set when new transfer is initiated' );
is( $transfer->comments, "Canceled, new transfer from $branchcode_1 to $branchcode_2 created" );

$schema->storage->txn_rollback;

