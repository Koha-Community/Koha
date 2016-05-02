#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 14;

use C4::Context;
use t::lib::TestBuilder;
use C4::Members;

use Koha::Patron::Modifications;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do("DELETE FROM borrower_modifications");

## Create new pending modification
Koha::Patron::Modifications->new( verification_token => '1234567890' )
  ->AddModifications( { surname => 'Hall', firstname => 'Kyle' } );

## Get the new pending modification
my $borrower = Koha::Patron::Modifications->GetModifications(
    { verification_token => '1234567890' } );

## Verify we get the same data
ok( $borrower->{'surname'} = 'Hall',
    'Test AddModifications() and GetModifications()' );

## Check the Verify method
ok(
    Koha::Patron::Modifications->Verify('1234567890'),
    'Test that Verify() succeeds with a valid token'
);

## Delete the pending modification
$borrower = Koha::Patron::Modifications->DelModifications(
    { verification_token => '1234567890' } );

## Verify it's no longer in the database
$borrower = Koha::Patron::Modifications->GetModifications(
    { verification_token => '1234567890' } );
ok( !defined( $borrower->{'surname'} ), 'Test DelModifications()' );

## Check the Verify method
ok(
    !Koha::Patron::Modifications->Verify('1234567890'),
    'Test that Verify() method fails for a bad token'
);

## Create new pending modification for a patron
my $builder = t::lib::TestBuilder->new;
my $borr1 = $builder->build({ source => 'Borrower' })->{borrowernumber};
Koha::Patron::Modifications->new( borrowernumber => $borr1 )
  ->AddModifications( { surname => 'Hall', firstname => 'Kyle' } );

## Test the counter
ok( Koha::Patron::Modifications->GetPendingModificationsCount() == 1,
    'Test GetPendingModificationsCount()' );

## Create new pending modification for another patron
my $borr2 = $builder->build({ source => 'Borrower' })->{borrowernumber};
Koha::Patron::Modifications->new( borrowernumber => $borr2 )
  ->AddModifications( { surname => 'Smith', firstname => 'Sandy' } );

## Test the counter
ok(
    Koha::Patron::Modifications->GetPendingModificationsCount() == 2,
'Add a new pending modification and test GetPendingModificationsCount() again'
);

## Check GetPendingModifications
my $pendings = Koha::Patron::Modifications->GetPendingModifications();
my @firstnames_mod = sort ( $pendings->[0]->{firstname}, $pendings->[1]->{firstname} );
ok( $firstnames_mod[0] eq 'Kyle', 'Test GetPendingModifications()' );
ok( $firstnames_mod[1] eq 'Sandy', 'Test GetPendingModifications() again' );

## This should delete the row from the table
Koha::Patron::Modifications->DenyModifications( $borr2 );

## Test the counter
ok( Koha::Patron::Modifications->GetPendingModificationsCount() == 1,
    'Test DenyModifications()' );

## Save a copy of the borrowers original data
my $old_borrower = GetMember( borrowernumber => $borr1 );

## Apply the modifications
Koha::Patron::Modifications->ApproveModifications( $borr1 );

## Test the counter
ok(
    Koha::Patron::Modifications->GetPendingModificationsCount() == 0,
    'Test ApproveModifications() removes pending modification from db'
);

## Get a copy of the borrowers current data
my $new_borrower = GetMember( borrowernumber => $borr1 );

## Check to see that the approved modifications were saved
ok( $new_borrower->{'surname'} eq 'Hall',
    'Test ApproveModifications() applys modification to borrower' );

## Now let's put it back the way it was
Koha::Patron::Modifications->new( borrowernumber => $borr1 )->AddModifications(
    {
        surname   => $old_borrower->{'surname'},
        firstname => $old_borrower->{'firstname'}
    }
);

## Test the counter
ok( Koha::Patron::Modifications->GetPendingModificationsCount() == 1,
    'Test GetPendingModificationsCount()' );

## Apply the modifications
Koha::Patron::Modifications->ApproveModifications( $borr1 );

## Test the counter
ok(
    Koha::Patron::Modifications->GetPendingModificationsCount() == 0,
    'Test ApproveModifications() removes pending modification from db, again'
);

$new_borrower = GetMember( borrowernumber => $borr1 );

## Test to verify the borrower has been updated with the original values
ok(
    $new_borrower->{'surname'} eq $old_borrower->{'surname'},
    'Test ApproveModifications() applys modification to borrower, again'
);

$dbh->rollback();
