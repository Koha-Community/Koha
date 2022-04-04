use Modern::Perl;
use Test::More tests => 3;

use C4::Serials;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM subscription|);

my $branchcode = 'CPL';
my $record = MARC::Record->new();
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio($record, '');

# Create a new subscription
my $subscriptionid_claims = C4::Serials::NewSubscription(
undef,      $branchcode,     undef, undef, undef, $biblionumber,
'2013-01-01', undef, undef, undef,  undef,
undef,      undef,  undef, undef, undef, undef,
1,          "notes",undef, '9999-01-01', undef, undef,
undef,       undef,  0,    "intnotes",  0,
undef, undef, 0,          undef,         '2013-12-31', 0
);

# Verify and get the serial ID of the subscription
my ( $totalissues, @serials ) = C4::Serials::GetSerials($subscriptionid_claims, 1);

C4::Serials::updateClaim( $serials[0]->{serialid} ); # Updating the claim
# sort the result to separate the CLAIMED and EXPECTED status
@serials = sort { $a->{serialid} <=> $b->{serialid} } @serials;

# Verify if serial IDs are correctly generated
( $totalissues, @serials ) = C4::Serials::GetSerials($subscriptionid_claims);

is ( scalar(@serials), 2, "le test est terminé" );  # Gives the length of the @serials

is ( ($serials[0]->{status}), C4::Serials::CLAIMED, "test CLAIMED" );
is ( ($serials[1]->{status}), C4::Serials::EXPECTED, "test EXPECTED" );
