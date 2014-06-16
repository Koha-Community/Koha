#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Members;

use Test::More tests => 22;

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
is( $success, 1, "AddDebarment returned true" );


my $debarments = GetDebarments({ borrowernumber => $borrowernumber });
is( @$debarments, 1, "GetDebarments returns 1 debarment" );
is( $debarments->[0]->{'type'}, 'MANUAL', "Correctly stored 'type'" );
is( $debarments->[0]->{'expiration'}, '9999-06-10', "Correctly stored 'expiration'" );
is( $debarments->[0]->{'comment'}, 'Test 1', "Correctly stored 'comment'" );


$success = AddDebarment({
    borrowernumber => $borrowernumber,
    comment => 'Test 2',
});

$debarments = GetDebarments({ borrowernumber => $borrowernumber });
is( @$debarments, 2, "GetDebarments returns 2 debarments" );
is( $debarments->[1]->{'type'}, 'MANUAL', "Correctly stored 'type'" );
is( $debarments->[1]->{'expiration'}, undef, "Correctly stored debarrment with no expiration" );
is( $debarments->[1]->{'comment'}, 'Test 2', "Correctly stored 'comment'" );


ModDebarment({
    borrower_debarment_id => $debarments->[1]->{'borrower_debarment_id'},
    comment => 'Test 3',
    expiration => '9998-06-10',
});
$debarments = GetDebarments({ borrowernumber => $borrowernumber });
is( $debarments->[1]->{'comment'}, 'Test 3', "ModDebarment functions correctly" );


my $borrower = GetMember( borrowernumber => $borrowernumber );
is( $borrower->{'debarred'}, '9999-06-10', "Field borrowers.debarred set correctly" );
is( $borrower->{'debarredcomment'}, "Test 1\nTest 3", "Field borrowers.debarredcomment set correctly" );


AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    type           => 'OVERDUES'
});
$debarments = GetDebarments({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
is( @$debarments, 1, "GetDebarments returns 1 OVERDUES debarment" );
is( $debarments->[0]->{'type'}, 'OVERDUES', "AddOverduesDebarment created new debarment correctly" );

AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    expiration => '9999-11-09',
    type => 'OVERDUES'
});
$debarments = GetDebarments({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
is( @$debarments, 1, "GetDebarments returns 1 OVERDUES debarment after running AddOverduesDebarment twice" );
is( $debarments->[0]->{'expiration'}, '9999-11-09', "AddOverduesDebarment updated OVERDUES debarment correctly" );


DelUniqueDebarment({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
$debarments = GetDebarments({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
is( @$debarments, 0, "DelUniqueDebarment functions correctly" );


$debarments = GetDebarments({ borrowernumber => $borrowernumber });
foreach my $d ( @$debarments ) {
    DelDebarment( $d->{'borrower_debarment_id'} );
}
$debarments = GetDebarments({ borrowernumber => $borrowernumber });
is( @$debarments, 0, "DelDebarment functions correctly" );

$dbh->do(q|UPDATE borrowers SET debarred = '1970-01-01'|);
is( IsDebarred( $borrowernumber ), undef, 'A patron with a debarred date in the past is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = NULL|);
is( IsDebarred( $borrowernumber ), undef, 'A patron without a debarred date is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = '9999-12-31'|); # Note: Change this test before the first of January 10000!
is( IsDebarred( $borrowernumber ), '9999-12-31', 'A patron with a debarred date in the future is debarred' );

$dbh->rollback;
