#!/usr/bin/perl

use Modern::Perl;
use C4::Biblio;
use C4::Context;
use C4::Items;
use C4::Branch;
use C4::Circulation;
use Koha::DateUtils;
use DateTime::Duration;

use Test::More tests => 12;

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

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM branch_transfer_limits|);
$dbh->do(q|DELETE FROM branchtransfers|);

#Add sample datas
#Add branches
my $samplebranch1 = {
    add            => 1,
    branchcode     => 'SAB1',
    branchname     => 'Sample Branch',
    branchaddress1 => 'sample adr1',
    branchaddress2 => 'sample adr2',
    branchaddress3 => 'sample adr3',
    branchzip      => 'sample zip',
    branchcity     => 'sample city',
    branchstate    => 'sample state',
    branchcountry  => 'sample country',
    branchphone    => 'sample phone',
    branchfax      => 'sample fax',
    branchemail    => 'sample email',
    branchurl      => 'sample url',
    branchip       => 'sample ip',
    branchprinter  => undef,
    opac_info      => 'sample opac',
};
my $samplebranch2 = {
    add            => 1,
    branchcode     => 'SAB2',
    branchname     => 'Sample Branch2',
    branchaddress1 => 'sample adr1_2',
    branchaddress2 => 'sample adr2_2',
    branchaddress3 => 'sample adr3_2',
    branchzip      => 'sample zip2',
    branchcity     => 'sample city2',
    branchstate    => 'sample state2',
    branchcountry  => 'sample country2',
    branchphone    => 'sample phone2',
    branchfax      => 'sample fax2',
    branchemail    => 'sample email2',
    branchurl      => 'sample url2',
    branchip       => 'sample ip2',
    branchprinter  => undef,
    opac_info      => 'sample opac2',
};
ModBranch($samplebranch1);
ModBranch($samplebranch2);

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
#FIXME :The following test should pass but doesn't because currently the routine CreateBranchTransferLimit returns nothing
#is(CreateBranchTransferLimit(),undef,"Without parameters CreateBranchTransferLimit returns undef");

#Test GetTransfers
my $dt_today = dt_from_string( undef, 'sql', undef );
my $today = $dt_today->strftime("%Y-%m-%d %H:%M:%S");

my @transfers = GetTransfers($item_id1);
is_deeply(
    \@transfers,
    [ $today, $samplebranch1->{branchcode}, $samplebranch2->{branchcode} ],
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
is_deeply(
    \@transferfrom1to2,
    [
        {
            itemnumber => $item_id1,
            datesent   => $today,
            frombranch => $samplebranch1->{branchcode}
        },
        {
            itemnumber => $item_id2,
            datesent   => $today,
            frombranch => $samplebranch1->{branchcode}
        }
    ],
    "Item1 and Item2 has been transfered from branch1 to branch2"
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
#FIXME :The following test should pass but doesn't because currently the routine DeleteBranchTransferLimit returns nothin
#is(C4::Circulation::DeleteBranchTransferLimits(),undef,"Without parameters DeleteBranchTransferLimit returns undef");

#Test DeleteTransfer
is( C4::Circulation::DeleteTransfer($item_id1),
    1, "A the item1's transfer has been deleted" );
#FIXME :The following tests should pass but don't because currently the routine DeleteTransfer returns nothing
#is(C4::Circulation::DeleteTransfer(),undef,"Without itemid DeleteTransfer returns undef");
#is(C4::Circulation::DeleteTransfer(-1),0,"with a wrong itemid DeleteTranfer returns 0");

#End transaction
$dbh->rollback;
