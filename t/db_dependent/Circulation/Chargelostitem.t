#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 6;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Circulation;
use MARC::Record;

BEGIN {
    use_ok('C4::Accounts');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM accountlines|);

t::lib::Mocks::mock_preference('ProcessingFeeNote', 'Test Note');

my $library = $builder->build({
    source => 'Branch',
});
my $branchcode = $library->{branchcode};

my $itemtype = $builder->build({
    source => 'Itemtype',
    value => {
        processfee => 42,
    }
});

my %item_branch_infos = (
    homebranch => $branchcode,
    holdingbranch => $branchcode,
    itype => $itemtype->{itemtype},
);

my ($biblionumber1) = AddBiblio(MARC::Record->new, '');
my $itemnumber1 = AddItem({ barcode => '0101', %item_branch_infos }, $biblionumber1);
my $itemnumber2 = AddItem({ barcode => '0102', %item_branch_infos }, $biblionumber1);

my ($biblionumber2) = AddBiblio(MARC::Record->new, '');
my $itemnumber3 = AddItem({ barcode => '0203', %item_branch_infos }, $biblionumber2);

my $categorycode = $builder->build({
    source => 'Category'
})->{categorycode};

my $borrowernumber = AddMember(categorycode => $categorycode, branchcode => $branchcode);
my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed();

# Need to mock userenv for AddIssue
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });
AddIssue($borrower, '0101');
AddIssue($borrower, '0203');

# Begin tests...
Koha::Account::Offsets->delete();
my $issue = Koha::Checkouts->search( { borrowernumber => $borrowernumber } )->next()->unblessed();
C4::Accounts::chargelostitem( $borrowernumber, $issue->{itemnumber}, '1.00');

my $accountline = Koha::Account::Lines->search( { borrowernumber => $borrowernumber, accounttype => 'PF' } )->next();

is( int($accountline->amount), int($itemtype->{processfee}), "The accountline amount should be precessfee value " );
is( $accountline->itemnumber, $itemnumber1, "The accountline itemnumber should the linked with barcode '0101'" );
is( $accountline->note, C4::Context->preference("ProcessingFeeNote"), "The accountline description should be 'test'" );

my $lost_ao = Koha::Account::Offsets->search( { type => 'Lost Item' } );
is( $lost_ao->count, 1, 'Account offset of type "Lost Item" created' );

my $processing_fee_ao = Koha::Account::Offsets->search( { type => 'Processing Fee' } );
is( $processing_fee_ao->count, 1, 'Account offset of type "Processing Fee" created' );
