#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Members;

use Test::More tests => 21;

use_ok('Koha::Borrower::Debarments');

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $borrowernumber = AddMember(
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => 'S',
    branchcode => 'CPL',
);

my $success = AddDebarment({
    borrowernumber => $borrowernumber,
    expiration => '9999-06-10',
    type => 'MANUAL',
    comment => 'Test 1',
});
ok( $success, "AddDebarment returned true" );


my $debarments = GetDebarments({ borrowernumber => $borrowernumber });
ok( @$debarments == 1, "GetDebarments returns 1 debarment" );
ok( $debarments->[0]->{'type'} eq 'MANUAL', "Correctly stored 'type'" );
ok( $debarments->[0]->{'expiration'} eq '9999-06-10', "Correctly stored 'expiration'" );
ok( $debarments->[0]->{'comment'} eq 'Test 1', "Correctly stored 'comment'" );


$success = AddDebarment({
    borrowernumber => $borrowernumber,
    comment => 'Test 2',
});

$debarments = GetDebarments({ borrowernumber => $borrowernumber });
ok( @$debarments == 2, "GetDebarments returns 2 debarments" );
ok( $debarments->[1]->{'type'} eq 'MANUAL', "Correctly stored 'type'" );
ok( !$debarments->[1]->{'expiration'}, "Correctly stored debarrment with no expiration" );
ok( $debarments->[1]->{'comment'} eq 'Test 2', "Correctly stored 'comment'" );


ModDebarment({
    borrower_debarment_id => $debarments->[1]->{'borrower_debarment_id'},
    comment => 'Test 3',
    expiration => '9998-06-10',
});
$debarments = GetDebarments({ borrowernumber => $borrowernumber });
ok( $debarments->[1]->{'comment'} eq 'Test 3', "ModDebarment functions correctly" );


my $borrower = GetMember( borrowernumber => $borrowernumber );
ok( $borrower->{'debarred'} eq '9999-06-10', "Field borrowers.debarred set correctly" );
ok( $borrower->{'debarredcomment'} eq "Test 1\nTest 3", "Field borrowers.debarredcomment set correctly" );


AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    type           => 'OVERDUES'
});
$debarments = GetDebarments({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
ok( @$debarments == 1, "GetDebarments returns 1 OVERDUES debarment" );
ok( $debarments->[0]->{'type'} eq 'OVERDUES', "AddOverduesDebarment created new debarment correctly" );

AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    expiration => '9999-11-09',
    type => 'OVERDUES'
});
$debarments = GetDebarments({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
ok( @$debarments == 1, "GetDebarments returns 1 OVERDUES debarment after running AddOverduesDebarment twice" );
ok( $debarments->[0]->{'expiration'} eq '9999-11-09', "AddOverduesDebarment updated OVERDUES debarment correctly" );


$debarments = GetDebarments({ borrowernumber => $borrowernumber });
foreach my $d ( @$debarments ) {
    DelDebarment( $d->{'borrower_debarment_id'} );
}
$debarments = GetDebarments({ borrowernumber => $borrowernumber });
ok( @$debarments == 0, "DelDebarment functions correctly" );

$dbh->do(q|UPDATE borrowers SET debarred = '1970-01-01'|);
is( IsDebarred( $borrowernumber ), undef, 'A patron with a debarred date in the past is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = NULL|);
is( IsDebarred( $borrowernumber ), undef, 'A patron without a debarred date is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = '9999-31-12'|); # Note: Change this test before the first of January 10000!
is( IsDebarred( $borrowernumber ), undef, 'A patron with a debarred date in the future is debarred' );

$dbh->rollback;
