use Modern::Perl;
use Test::More tests => 4;
use t::lib::TestBuilder;

# Please add more tests here !!

use t::lib::Mocks;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Circulation;
use C4::Members::Statistics;
use Koha::Database; # we need the db here; get_fields looks for the item columns
use Data::Dumper;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM categories|);

my $branchcode   = $builder->build( { source => 'Branch' } )->{branchcode};
my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
my $itemtype     = $builder->build( { source => 'Itemtype' } )->{itemtype};

my %item_infos = (
    homebranch    => $branchcode,
    holdingbranch => $branchcode,
    itype         => $itemtype
);


my ($biblionumber1) = AddBiblio( MARC::Record->new, '' );
my $itemnumber1 =
  AddItem( { barcode => '0101', %item_infos }, $biblionumber1 );

my ($biblionumber2) = AddBiblio( MARC::Record->new, '' );
my $itemnumber2 =
  AddItem( { barcode => '0203', %item_infos }, $biblionumber2 );

my $borrowernumber =
  AddMember( categorycode => $categorycode, branchcode => $branchcode );
my $borrower = GetMember( borrowernumber => $borrowernumber );

my $module = new Test::MockModule('C4::Context');
$module->mock( 'userenv', sub { { branch => $branchcode } } );

my $noissues = C4::Members::Statistics::GetTotalIssuesTodayByBorrower($borrowernumber);

is( scalar(@$noissues), 0, 'No items checked out today' );

AddIssue( $borrower, '0101' );
AddIssue( $borrower, '0203' );

my $issues = C4::Members::Statistics::GetTotalIssuesTodayByBorrower($borrowernumber);

my $count_total_issues;

for my $hash ( @$issues ) {
	$count_total_issues = $hash->{count_total_issues_today};
}

is( $count_total_issues, 2, '2 items checked out today' );

t::lib::Mocks::mock_preference( 'StatisticsFields', undef );
is( C4::Members::Statistics::get_fields(), 'location|itype|ccode', 'Check default' );

t::lib::Mocks::mock_preference( 'StatisticsFields', 'barcode|garbagexxx|itemcallnumber|notexistent' );
is( C4::Members::Statistics::get_fields(), 'barcode|itemcallnumber', 'Check if wrong item fields were removed by get_fields' );

$schema->storage->txn_rollback;
