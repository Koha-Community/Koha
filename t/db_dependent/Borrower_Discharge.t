#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 17;
use Test::Warn;
use MARC::Record;

use C4::Biblio qw( AddBiblio );
use C4::Circulation qw( AddIssue AddReturn );
use C4::Context;
use C4::Items qw( AddItem );
use C4::Members qw( AddMember GetMember );

use Koha::Borrower::Discharge;
use Koha::Database;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM discharges|);

my $library = $builder->build({
    source => 'Branch',
});
my $another_library = $builder->build({
    source => 'Branch',
});

C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0, 0, 0, 'firstname', 'surname', $library->{branchcode}, $library->{branchcode}, '', '', '', '', '');
my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library->{branchcode},
    }
});
my $borrower2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library->{branchcode},
    }
});
my $borrower3 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $another_library->{branchcode},
    }
});

# Discharge not possible with issues
my ( $biblionumber ) = AddBiblio( MARC::Record->new, '');
my $barcode = 'BARCODE42';
my ( undef, undef, $itemnumber ) = AddItem({ homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode}, barcode => $barcode }, $biblionumber);
AddIssue( $borrower, $barcode );
is( Koha::Borrower::Discharge::can_be_discharged({ borrowernumber => $borrower->{borrowernumber} }), 0, 'A patron with issues cannot be discharged' );

is( Koha::Borrower::Discharge::request({ borrowernumber => $borrower->{borrowernumber} }), undef, 'No request done if patron has issues' );
is( Koha::Borrower::Discharge::discharge({ borrowernumber => $borrower->{borrowernumber} }), undef, 'No discharge done if patron has issues' );
is_deeply( Koha::Borrower::Discharge::get_pendings(), [], 'There is no pending discharge request' );
is_deeply( Koha::Borrower::Discharge::get_validated(), [], 'There is no validated discharge' );

AddReturn( $barcode );

# Discharge possible without issue
is( Koha::Borrower::Discharge::can_be_discharged({ borrowernumber => $borrower->{borrowernumber} }), 1, 'A patron without issues can be discharged' );

is(Koha::Borrower::Discharge::generate_as_pdf,undef,"Confirm failure when lacking borrower number");

# Verify that the user is not discharged anymore if the restriction has been lifted
Koha::Borrower::Discharge::discharge( { borrowernumber => $borrower->{borrowernumber} } );
Koha::Borrower::Discharge::discharge( { borrowernumber => $borrower2->{borrowernumber} } );
Koha::Borrower::Discharge::discharge( { borrowernumber => $borrower3->{borrowernumber} } );
is( Koha::Borrower::Discharge::is_discharged( { borrowernumber => $borrower->{borrowernumber} } ), 1, 'The patron has been discharged' );
is( Koha::Borrower::Debarments::IsDebarred( $borrower->{borrowernumber} ), '9999-12-31', 'The patron has been debarred after discharge' );
is( scalar( @{ Koha::Borrower::Discharge::get_validated() } ),             3,            'There are 3 validated discharges' );
is( scalar( @{ Koha::Borrower::Discharge::get_validated( { borrowernumber => $borrower->{borrowernumber} } ) } ), 1, 'There is 1 validated discharge for a given patron' );
is( scalar( @{ Koha::Borrower::Discharge::get_validated( { branchcode => $library->{branchcode} } ) } ), 2, 'There is 2 validated discharges for a given branchcode' );    # This is not used in the code yet
Koha::Borrower::Debarments::DelUniqueDebarment( { 'borrowernumber' => $borrower->{borrowernumber}, 'type' => 'DISCHARGE' } );
ok( !Koha::Borrower::Debarments::IsDebarred( $borrower->{borrowernumber} ), 'The debarment has been lifted' );
ok( !Koha::Borrower::Discharge::is_discharged( { borrowernumber => $borrower->{borrowernumber} } ), 'The patron is not discharged after the restriction has been lifted' );

# Verify that the discharge works multiple times
Koha::Borrower::Discharge::request({ borrowernumber => $borrower->{borrowernumber} });
is(scalar( @{ Koha::Borrower::Discharge::get_pendings() }), 1, 'There is a pending discharge request (second time)');
Koha::Borrower::Discharge::discharge( { borrowernumber => $borrower->{borrowernumber} } );
is_deeply( Koha::Borrower::Discharge::get_pendings(), [], 'There is no pending discharge request (second time)');

# Check if PDF::FromHTML is installed.
my $check = eval { require PDF::FromHTML; };

# Tests for if PDF::FromHTML is installed
if ($check) {
    isnt( Koha::Borrower::Discharge::generate_as_pdf({ borrowernumber => $borrower->{borrowernumber} }), undef, "Temporary PDF generated." );
}
# Tests for if PDF::FromHTML is not installed
else {
    warning_like { Koha::Borrower::Discharge::generate_as_pdf({ borrowernumber => $borrower->{borrowernumber}, testing => 1 }) }
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
#is( Koha::Service::Borrower::Discharge::request({ borrowernumber => $borrower->{borrowernumber} }), 1, 'Discharge request sent' );

$schema->storage->txn_rollback;

1;
