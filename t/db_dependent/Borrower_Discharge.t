#!/usr/bin/perl;

use Modern::Perl;
use Test::More;
use Test::Warn;
use MARC::Record;

use C4::Biblio qw( AddBiblio );
use C4::Circulation qw( AddIssue AddReturn );
use C4::Context;
use C4::Items qw( AddItem );
use C4::Members qw( AddMember GetMember );

use Koha::Borrower::Discharge;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM discharges|);

C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0, 0, 0, 'firstname', 'surname', 'CPL', 'CPL', '', '', '', '', '');

my $borrowernumber = AddMember(
    cardnumber => 'UTCARD1',
    firstname => 'my firstname',
    surname => 'my surname',
    categorycode => 'S',
    branchcode => 'CPL',
);
my $borrower = GetMember( borrowernumber => $borrowernumber );

# Discharge not possible with issues
my ( $biblionumber ) = AddBiblio( MARC::Record->new, '');
my $barcode = 'BARCODE42';
my ( undef, undef, $itemnumber ) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL', barcode => $barcode }, $biblionumber);
AddIssue( $borrower, $barcode );
is( Koha::Borrower::Discharge::can_be_discharged({ borrowernumber => $borrowernumber }), 0, 'A patron with issues cannot be discharged' );

is( Koha::Borrower::Discharge::request({ borrowernumber => $borrowernumber }), undef, 'No request done if patron has issues' );
is( Koha::Borrower::Discharge::discharge({ borrowernumber => $borrowernumber }), undef, 'No discharge done if patron has issues' );
is_deeply( Koha::Borrower::Discharge::get_pendings(), [], 'There is no pending discharge request' );

AddReturn( $barcode );

# Discharge possible without issue
is( Koha::Borrower::Discharge::can_be_discharged({ borrowernumber => $borrowernumber }), 1, 'A patron without issues can be discharged' );

is(Koha::Borrower::Discharge::generate_as_pdf,undef,"Confirm failure when lacking borrower number");

# Verify that the user is not discharged anymore if the restriction has been lifted
Koha::Borrower::Discharge::discharge({ borrowernumber => $borrowernumber });
is( Koha::Borrower::Discharge::is_discharged({ borrowernumber => $borrowernumber }), 1, 'The patron has been discharged' );
is(Koha::Borrower::Debarments::IsDebarred($borrowernumber), '9999-12-31', 'The patron has been debarred after discharge');
Koha::Borrower::Debarments::DelUniqueDebarment({'borrowernumber' => $borrowernumber, 'type' => 'DISCHARGE'});
ok(! Koha::Borrower::Debarments::IsDebarred($borrowernumber), 'The debarment has been lifted');
ok(! Koha::Borrower::Discharge::is_discharged({ borrowernumber => $borrowernumber }), 'The patron is not discharged after the restriction has been lifted' );

# Check if PDF::FromHTML is installed.
my $check = eval { require PDF::FromHTML; };

# Tests for if PDF::FromHTML is installed
if ($check) {
    isnt( Koha::Borrower::Discharge::generate_as_pdf({ borrowernumber => $borrowernumber }), undef, "Temporary PDF generated." );
}
# Tests for if PDF::FromHTML is not installed
else {
    warning_like { Koha::Borrower::Discharge::generate_as_pdf({ borrowernumber => $borrowernumber, testing => 1 }) }
          [ qr/Can't locate PDF\/FromHTML.pm in \@INC/ ],
          "Expected failure because of missing PDF::FromHTML.";
}

# FIXME
# At this point, there is a problem with the AutoCommit off
# The transaction is bloked into DBIx::Class::Storage::DBI::_dbh_execute
# line my $rv = $sth->execute();
# We are using 2 connections and the one used by Koha::Schema has the AutoCommit set to 1
# Even if we switch off this flag, the connection will be blocked.
# The error is:
# DBIx::Class::ResultSet::create(): DBI Exception: DBD::mysql::st execute failed: Lock wait timeout exceeded; try restarting transaction [for Statement "INSERT INTO discharges ( borrower, needed, validated) VALUES ( ?, ?, ? )" with ParamValues: 0='121', 1='2014-01-08T16:38:29', 2=undef] at /home/koha/src/Koha/DataObject/Discharge.pm line 33
#is( Koha::Service::Borrower::Discharge::request({ borrowernumber => $borrowernumber }), 1, 'Discharge request sent' );

done_testing;
