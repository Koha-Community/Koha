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
use C4::Context;
use C4::Circulation qw( CreateBranchTransferLimit DeleteBranchTransferLimits GetTransfersFromTo TransferSlip );
use C4::Biblio      qw( AddBiblio );
use C4::Items       qw( ModItemTransfer );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use DateTime::Duration;
use Koha::Item::Transfers;

use t::lib::TestBuilder;

use Test::NoWarnings;
use Test::More tests => 20;
use Test::Deep;

BEGIN {
    use_ok(
        'C4::Circulation',
        qw( CreateBranchTransferLimit DeleteBranchTransferLimits GetTransfersFromTo TransferSlip )
    );
}
can_ok(
    'C4::Circulation',
    qw(
        CreateBranchTransferLimit
        DeleteBranchTransferLimits
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
my $branchcode_3 = $builder->build( { source => 'Branch', } )->{branchcode};

# Add itemtype
my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};

#Add biblio and items
my $record = MARC::Record->new();
$record->append_fields( MARC::Field->new( '952', '0', '0', a => $branchcode_1 ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '', );

my $item_id1 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 1,
        itemcallnumber => 'callnumber1',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        itype          => $itemtype
    },
)->store->itemnumber;
my $item_id2 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 2,
        itemcallnumber => 'callnumber2',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        itype          => $itemtype
    },
)->store->itemnumber;
my $item_id3 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 3,
        itemcallnumber => 'callnumber3',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        itype          => $itemtype
    },
)->store->itemnumber;
my $item_id4 = Koha::Item->new(
    {
        biblionumber   => $biblionumber,
        barcode        => 4,
        itemcallnumber => 'callnumber4',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        itype          => $itemtype
    },
)->store->itemnumber;

#Add transfers
my $trigger = 'Manual';
ModItemTransfer(
    $item_id1,
    $branchcode_1,
    $branchcode_2,
    $trigger
);

my $item_obj = Koha::Items->find( { itemnumber => $item_id1 } );
is( $item_obj->holdingbranch, $branchcode_1, "Item should be held at branch that initiates transfer" );

ModItemTransfer(
    $item_id2,
    $branchcode_1,
    $branchcode_2,
    $trigger
);

# Add an "unsent" transfer for tests
ModItemTransfer(
    $item_id3,
    $branchcode_1,
    $branchcode_2,
    $trigger
);
my $transfer_requested = Koha::Item::Transfers->search( { itemnumber => $item_id3 }, { rows => 1 } )->single;
$transfer_requested->set( { daterequested => dt_from_string, datesent => undef } )->store;

# Add a "cancelled" transfer for tests
ModItemTransfer(
    $item_id4,
    $branchcode_1,
    $branchcode_2,
    $trigger
);
my $transfer_cancelled = Koha::Item::Transfers->search( { itemnumber => $item_id4 }, { rows => 1 } )->single;
$transfer_cancelled->set( { daterequested => dt_from_string, datesent => undef, datecancelled => dt_from_string } )
    ->store;

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
is(
    CreateBranchTransferLimit(), undef,
    "Without parameters CreateBranchTransferLimit returns undef"
);
is(
    CreateBranchTransferLimit($branchcode_2), undef,
    "With only tobranch CreateBranchTransferLimit returns undef"
);
is(
    CreateBranchTransferLimit( undef, $branchcode_2 ), undef,
    "With only frombranch CreateBranchTransferLimit returns undef"
);

#FIXME: Currently, we can add a transferlimit even to nonexistent branches because in the database,
#branch_transfer_limits.toBranch and branch_transfer_limits.fromBranch aren't foreign keys
#is(CreateBranchTransferLimit(-1,-1,'CODE'),0,"With wrong CreateBranchTransferLimit returns 0 - No transfertlimit added");

#Test GetTransfersFromTo
my @transferfrom1to2 = GetTransfersFromTo(
    $branchcode_1,
    $branchcode_2
);
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
is_deeply(
    \@transferto, [],
    "GetTransfersfromTo without frombranch returns an empty array"
);
my @transferfrom = GetTransfersFromTo($branchcode_1);
is_deeply(
    \@transferfrom, [],
    "GetTransfersfromTo without tobranch returns an empty array"
);
@transferfrom = GetTransfersFromTo();
is_deeply(
    \@transferfrom, [],
    "GetTransfersfromTo without params returns an empty array"
);

#Test DeleteBranchTransferLimits
is(
    C4::Circulation::DeleteBranchTransferLimits($branchcode_1),
    1,
    "A Branch TransferLimit has been deleted"
);
is(
    C4::Circulation::DeleteBranchTransferLimits(), undef,
    "Without parameters DeleteBranchTransferLimit returns undef"
);
is( C4::Circulation::DeleteBranchTransferLimits('B'), '0E0', "With a wrong id DeleteBranchTransferLimit returns 0E0" );

#Test TransferSlip
is(
    C4::Circulation::TransferSlip( $branchcode_1, undef, 5, $branchcode_2 ),
    undef, "No tranferslip if invalid or undef itemnumber or barcode"
);
is(
    C4::Circulation::TransferSlip( $branchcode_1, $item_id1, 1, $branchcode_2 )->{'code'},
    'TRANSFERSLIP', "Get a transferslip on valid itemnumber and/or barcode"
);
cmp_deeply(
    C4::Circulation::TransferSlip( $branchcode_1, $item_id1, undef, $branchcode_2 ),
    C4::Circulation::TransferSlip( $branchcode_1, undef,     1,     $branchcode_2 ),
    "Barcode and itemnumber for same item both generate same TransferSlip"
);

$dbh->do("DELETE FROM branchtransfers");
ModItemTransfer(
    $item_id1,
    $branchcode_1,
    $branchcode_2,
    $trigger
);
my $transfer = Koha::Item::Transfers->search()->next();
ModItemTransfer(
    $item_id1,
    $branchcode_1,
    $branchcode_3,
    $trigger
);
$transfer->{_result}->discard_changes;
ok( $transfer->datecancelled, 'Date cancelled is set when new transfer is initiated' );
is( $transfer->cancellation_reason, "Manual", 'Cancellation reason is set correctly when new transfer is initiated' );

$schema->storage->txn_rollback;

