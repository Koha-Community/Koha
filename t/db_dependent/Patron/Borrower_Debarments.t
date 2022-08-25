#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use Koha::Database;
use Koha::Patrons;

use t::lib::TestBuilder;

use Test::More tests => 34;

use_ok('Koha::Patron::Debarments');

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

my $library = $builder->build({
    source => 'Branch',
});

my $patron_category = $builder->build({ source => 'Category' });
my $patron = $builder->build_object(
    {
        class  => 'Koha::Patrons',
        value => {
            firstname    => 'my firstname',
            surname      => 'my surname',
            categorycode => $patron_category->{categorycode},
            branchcode   => $library->{branchcode},
        }
    }
);
my $borrowernumber = $patron->borrowernumber;

my $success = Koha::Patron::Debarments::AddDebarment({
    borrowernumber => $borrowernumber,
    expiration => '9999-06-10',
    type => 'MANUAL',
    comment => 'Test 1',
});
is( $success, 1, "AddDebarment returned true" );


my $restrictions = $patron->restrictions;
my $THE_restriction = $restrictions->next;
is( $restrictions->count, 1, '$patron->restrictions returns 1 restriction' );
is( $THE_restriction->type->code, 'MANUAL', "Correctly stored 'type'" );
is( $THE_restriction->expiration, '9999-06-10', "Correctly stored 'expiration'" );
is( $THE_restriction->comment, 'Test 1', "Correctly stored 'comment'" );


$success = Koha::Patron::Debarments::AddDebarment({
    borrowernumber => $borrowernumber,
    comment => 'Test 2',
});

$restrictions = $patron->restrictions;
$THE_restriction = $restrictions->last;
is( $restrictions->count, 2, '$patron->restrictions returns 2 restrictions' );
is( $THE_restriction->type->code, 'MANUAL', "Correctly stored 'type'" );
is( $THE_restriction->expiration, undef, "Correctly stored debarrment with no expiration" );
is( $THE_restriction->comment, 'Test 2', "Correctly stored 'comment'" );


Koha::Patron::Debarments::ModDebarment({
    borrower_debarment_id => $THE_restriction->borrower_debarment_id,
    comment => 'Test 3',
    expiration => '9998-06-10',
});

$restrictions = $patron->restrictions;
$THE_restriction = $restrictions->last;
is( $restrictions->count, 2, '$patron->restrictions returns 2 restrictions' );
is( $THE_restriction->comment, 'Test 3', "ModDebarment functions correctly" );

$patron = $patron->get_from_storage;
is( $patron->debarred, '9999-06-10', "Field borrowers.debarred set correctly" );
is( $patron->debarredcomment, "Test 1\nTest 3", "Field borrowers.debarredcomment set correctly" );


Koha::Patron::Debarments::AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    type           => 'OVERDUES'
});

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
$THE_restriction = $restrictions->next;
is( $restrictions->count, 1, '$patron->restrictions->search({ type => "OVERDUES" }) returns 1 OVERDUES restriction after running AddUniqueDebarment once' );
is( $THE_restriction->type->code, 'OVERDUES', "AddOverduesDebarment created new debarment correctly" );

Koha::Patron::Debarments::AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    expiration => '9999-11-09',
    type => 'OVERDUES'
});

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
$THE_restriction = $restrictions->next;
is( $restrictions->count, 1, '$patron->restrictions->search({ type => "OVERDUES" }) returns 1 OVERDUES restriction after running AddUniqueDebarent twice' );
is( $THE_restriction->expiration, '9999-11-09', "AddUniqueDebarment updated the OVERDUES restriction correctly" );


my $delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment({
});
is( $delUniqueDebarment, undef, "DelUniqueDebarment without the arguments 'borrowernumber' and 'type' returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment without the arguments 'borrowernumber' and 'type' does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment({
    borrowernumber => $borrowernumber,
});
is( $delUniqueDebarment, undef, "DelUniqueDebarment without the argument 'type' returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment without the argument 'type' does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment({
    type => 'OVERDUES'
});
is( $delUniqueDebarment, undef, "DelUniqueDebarment without the argument 'borrowernumber' returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment without the argument 'borrowerumber' does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment({
    borrowernumber => $borrowernumber,
    type => 'SUSPENSION',
});
is( $delUniqueDebarment, undef, "DelUniqueDebarment with wrong arguments returns undef" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 1, "DelUniqueDebarment with wrong arguments does not delete the debarment" );

$delUniqueDebarment = Koha::Patron::Debarments::DelUniqueDebarment({
    borrowernumber => $borrowernumber,
    type => 'OVERDUES',
});
is( $delUniqueDebarment, 1, "DelUniqueDebarment returns 1" );

$restrictions = $patron->restrictions->search(
    {
        type => 'OVERDUES',
    }
);
is( $restrictions->count, 0, "DelUniqueDebarment functions correctly" );

$restrictions = $patron->restrictions;
while ( my $restriction = $restrictions->next ) {
    Koha::Patron::Debarments::DelDebarment( $restriction->borrower_debarment_id );
}

$restrictions = $patron->restrictions;
is( $restrictions->count, 0, "DelDebarment functions correctly" );

$dbh->do(q|UPDATE borrowers SET debarred = '1970-01-01'|);
is( Koha::Patrons->find( $borrowernumber )->is_debarred, undef, 'A patron with a debarred date in the past is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = NULL|);
is( Koha::Patrons->find( $borrowernumber )->is_debarred, undef, 'A patron without a debarred date is not debarred' );

$dbh->do(q|UPDATE borrowers SET debarred = '9999-12-31'|); # Note: Change this test before the first of January 10000!
is( Koha::Patrons->find( $borrowernumber )->is_debarred, '9999-12-31', 'A patron with a debarred date in the future is debarred' );

# Test patrons merge
my $borrowernumber2 = Koha::Patron->new(
    {
        firstname    => 'my firstname bis',
        surname      => 'my surname bis',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library->{branchcode},
    }
)->store->borrowernumber;
my $debarreddate2    = '9999-06-10'; # Be sure to be in the future
my $debarredcomment2 = 'Test merge';
Koha::Patron::Debarments::AddDebarment(
    {
        borrowernumber => $borrowernumber2,
        expiration     => $debarreddate2,
        type           => 'MANUAL',
        comment        => $debarredcomment2,
    }
);
my $borrowernumber3 = Koha::Patron->new(
    {
        firstname    => 'my firstname ter',
        surname      => 'my surname ter',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library->{branchcode},
    }
)->store->borrowernumber;
Koha::Patrons->find($borrowernumber3)->merge_with( [$borrowernumber2] );
is( Koha::Patrons->find($borrowernumber3)->debarred,
    $debarreddate2, 'Koha::Patron->merge_with() transfers well debarred' );
is( Koha::Patrons->find($borrowernumber3)->debarredcomment,
    $debarredcomment2, 'Koha::Patron->merge_with() transfers well debarredcomment' );
