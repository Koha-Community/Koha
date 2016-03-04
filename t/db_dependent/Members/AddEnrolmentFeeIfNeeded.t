use Modern::Perl;
use Test::More tests => 4;

use C4::Context;
use C4::Members;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $library = $builder->build({
    source => 'Branch',
});

my $enrolmentfee_K = 5;
my $enrolmentfee_J = 10;
my $enrolmentfee_YA = 20;

$dbh->do(q{
    UPDATE categories
    SET enrolmentfee=?
    WHERE categorycode=?
}, {}, $enrolmentfee_K, 'K' );

$dbh->do(q{
    UPDATE categories
    SET enrolmentfee=?
    WHERE categorycode=?
}, {}, $enrolmentfee_J, 'J' );

$dbh->do(q{
    UPDATE categories
    SET enrolmentfee=?
    WHERE categorycode=?
}, {}, $enrolmentfee_YA, 'YA' );

my %borrower_data = (
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => 'K',
    branchcode => $library->{branchcode},
);

my $borrowernumber = C4::Members::AddMember( %borrower_data );
$borrower_data{borrowernumber} = $borrowernumber;

my ( $total ) = C4::Members::GetMemberAccountRecords( $borrowernumber );
is( $total, $enrolmentfee_K, "New kid pay $enrolmentfee_K" );

t::lib::Mocks::mock_preference( 'FeeOnChangePatronCategory', 0 );
$borrower_data{categorycode} = 'J';
C4::Members::ModMember( %borrower_data );
( $total ) = C4::Members::GetMemberAccountRecords( $borrowernumber );
is( $total, $enrolmentfee_K , "Kid growing and become a juvenile, but shouldn't pay for the upgrade ");

$borrower_data{categorycode} = 'K';
C4::Members::ModMember( %borrower_data );
t::lib::Mocks::mock_preference( 'FeeOnChangePatronCategory', 1 );

$borrower_data{categorycode} = 'J';
C4::Members::ModMember( %borrower_data );
( $total ) = C4::Members::GetMemberAccountRecords( $borrowernumber );
is( $total, $enrolmentfee_K + $enrolmentfee_J, "Kid growing and become a juvenile, he should pay " . ( $enrolmentfee_K + $enrolmentfee_J ) );

# Check with calling directly AddEnrolmentFeeIfNeeded
C4::Members::AddEnrolmentFeeIfNeeded( 'YA', $borrowernumber );
( $total ) = C4::Members::GetMemberAccountRecords( $borrowernumber );
is( $total, $enrolmentfee_K + $enrolmentfee_J + $enrolmentfee_YA, "Juvenile growing and become an young adult, he should pay " . ( $enrolmentfee_K + $enrolmentfee_J + $enrolmentfee_YA ) );
