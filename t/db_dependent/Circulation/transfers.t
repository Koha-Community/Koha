#!/usr/bin/perl

use Modern::Perl;
use C4::Biblio;
use C4::Context;
use C4::Items;
use C4::Circulation;
use Koha::Database;
use Koha::DateUtils;
use DateTime::Duration;

use t::lib::TestBuilder;

use Test::More tests => 22;
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

#Add sample datas
#Add branches
my $samplebranch1 = $builder->build({
    source => 'Branch',
});
my $samplebranch2 = $builder->build({
    source => 'Branch',
});

#Add biblio and items
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => $samplebranch1->{branchcode} ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '', );

my @sampleitem1 = C4::Items::AddItem(
    {
        barcode        => 1,
        itemcallnumber => 'callnumber1',
        homebranch     => $samplebranch1->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode}
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];
my @sampleitem2 = C4::Items::AddItem(
    {
        barcode        => 2,
        itemcallnumber => 'callnumber2',
        homebranch     => $samplebranch1->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode}
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];

#Add transfers
ModItemTransfer(
    $item_id1,
    $samplebranch1->{branchcode},
    $samplebranch2->{branchcode}
);
ModItemTransfer(
    $item_id2,
    $samplebranch1->{branchcode},
    $samplebranch2->{branchcode}
);

#Begin Tests
#Test CreateBranchTransferLimit
is(
    CreateBranchTransferLimit(
        $samplebranch2->{branchcode},
        $samplebranch1->{branchcode}, 'CODE'
    ),
    1,
    "A Branch TransferLimit has been added"
);
is(CreateBranchTransferLimit(),undef,
    "Without parameters CreateBranchTransferLimit returns undef");
is(CreateBranchTransferLimit($samplebranch2->{branchcode}),undef,
    "With only tobranch CreateBranchTransferLimit returns undef");
is(CreateBranchTransferLimit(undef,$samplebranch2->{branchcode}),undef,
    "With only frombranch CreateBranchTransferLimit returns undef");
#FIXME: Currently, we can add a transferlimit even to nonexistent branches because in the database,
#branch_transfer_limits.toBranch and branch_transfer_limits.fromBranch aren't foreign keys
#is(CreateBranchTransferLimit(-1,-1,'CODE'),0,"With wrong CreateBranchTransferLimit returns 0 - No transfertlimit added");

#Test GetTransfers
my @transfers = GetTransfers($item_id1);
cmp_deeply(
    \@transfers,
    [ re('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'), $samplebranch1->{branchcode}, $samplebranch2->{branchcode} ],
    "Transfers of the item1"
);    #NOTE: Only the first transfer is returned
@transfers = GetTransfers;
is_deeply( \@transfers, [],
    "GetTransfers without params returns an empty array" );
@transfers = GetTransfers(-1);
is_deeply( \@transfers, [],
    "GetTransfers with a wrong item id returns an empty array" );

#Test GetTransfersFromTo
my @transferfrom1to2 = GetTransfersFromTo( $samplebranch1->{branchcode},
    $samplebranch2->{branchcode} );
cmp_deeply(
    \@transferfrom1to2,
    [
        {
            itemnumber => $item_id1,
            datesent   => re('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'),
            frombranch => $samplebranch1->{branchcode}
        },
        {
            itemnumber => $item_id2,
            datesent   => re('^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'),
            frombranch => $samplebranch1->{branchcode}
        }
    ],
    "Item1 and Item2 has been transferred from branch1 to branch2"
);
my @transferto = GetTransfersFromTo( undef, $samplebranch2->{branchcode} );
is_deeply( \@transferto, [],
    "GetTransfersfromTo without frombranch returns an empty array" );
my @transferfrom = GetTransfersFromTo( $samplebranch1->{branchcode} );
is_deeply( \@transferfrom, [],
    "GetTransfersfromTo without tobranch returns an empty array" );
@transferfrom = GetTransfersFromTo();
is_deeply( \@transferfrom, [],
    "GetTransfersfromTo without params returns an empty array" );

#Test DeleteBranchTransferLimits
is(
    C4::Circulation::DeleteBranchTransferLimits( $samplebranch1->{branchcode} ),
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
is( C4::Circulation::TransferSlip($samplebranch1->{branchcode}, undef, 5, $samplebranch2->{branchcode}),
    undef, "No tranferslip if invalid or undef itemnumber or barcode" );
is( C4::Circulation::TransferSlip($samplebranch1->{branchcode}, $item_id1, 1, $samplebranch2->{branchcode})->{'code'},
    'TRANSFERSLIP', "Get a transferslip on valid itemnumber and/or barcode" );
cmp_deeply(
    C4::Circulation::TransferSlip($samplebranch1->{branchcode}, $item_id1, undef, $samplebranch2->{branchcode}),
    C4::Circulation::TransferSlip($samplebranch1->{branchcode}, undef, 1, $samplebranch2->{branchcode}),
    "Barcode and itemnumber for same item both generate same TransferSlip"
    );
