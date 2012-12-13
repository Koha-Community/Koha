#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 14;

use C4::Context;
use C4::Members;

use Koha::Borrower::Modifications;

C4::Context->dbh->do("TRUNCATE TABLE borrower_modifications");

## Create new pending modification
Koha::Borrower::Modifications->new( verification_token => '1234567890' )
  ->AddModifications( { surname => 'Hall', firstname => 'Kyle' } );

## Get the new pending modification
my $borrower = Koha::Borrower::Modifications->GetModifications(
    { verification_token => '1234567890' } );

## Verify we get the same data
ok( $borrower->{'surname'} = 'Hall',
    'Test AddModifications() and GetModifications()' );

## Check the Verify method
ok(
    Koha::Borrower::Modifications->Verify('1234567890'),
    'Test that Verify() succeeds with a valid token'
);

## Delete the pending modification
$borrower = Koha::Borrower::Modifications->DelModifications(
    { verification_token => '1234567890' } );

## Verify it's no longer in the database
$borrower = Koha::Borrower::Modifications->GetModifications(
    { verification_token => '1234567890' } );
ok( !defined( $borrower->{'surname'} ), 'Test DelModifications()' );

## Check the Verify method
ok(
    !Koha::Borrower::Modifications->Verify('1234567890'),
    'Test that Verify() method fails for a bad token'
);

## Create new pending modification, but for an existing borrower
Koha::Borrower::Modifications->new( borrowernumber => '2' )
  ->AddModifications( { surname => 'Hall', firstname => 'Kyle' } );

## Test the counter
ok( Koha::Borrower::Modifications->GetPendingModificationsCount() == 1,
    'Test GetPendingModificationsCount()' );

## Create new pending modification for another existing borrower
Koha::Borrower::Modifications->new( borrowernumber => '3' )
  ->AddModifications( { surname => 'Smith', firstname => 'Sandy' } );

## Test the counter
ok(
    Koha::Borrower::Modifications->GetPendingModificationsCount() == 2,
'Add a new pending modification and test GetPendingModificationsCount() again'
);

## Check GetPendingModifications
my $pending = Koha::Borrower::Modifications->GetPendingModifications();
ok( $pending->[0]->{'firstname'} eq 'Kyle', 'Test GetPendingModifications()' );
ok(
    $pending->[1]->{'firstname'} eq 'Sandy',
    'Test GetPendingModifications() again'
);

## This should delete the row from the table
Koha::Borrower::Modifications->DenyModifications('3');

## Test the counter
ok( Koha::Borrower::Modifications->GetPendingModificationsCount() == 1,
    'Test DenyModifications()' );

## Save a copy of the borrowers original data
my $old_borrower = GetMember( borrowernumber => '2' );

## Apply the modifications
Koha::Borrower::Modifications->ApproveModifications('2');

## Test the counter
ok(
    Koha::Borrower::Modifications->GetPendingModificationsCount() == 0,
    'Test ApproveModifications() removes pending modification from db'
);

## Get a copy of the borrowers current data
my $new_borrower = GetMember( borrowernumber => '2' );

## Check to see that the approved modifications were saved
ok( $new_borrower->{'surname'} eq 'Hall',
    'Test ApproveModifications() applys modification to borrower' );

## Now let's put it back the way it was
Koha::Borrower::Modifications->new( borrowernumber => '2' )->AddModifications(
    {
        surname   => $old_borrower->{'surname'},
        firstname => $old_borrower->{'firstname'}
    }
);

## Test the counter
ok( Koha::Borrower::Modifications->GetPendingModificationsCount() == 1,
    'Test GetPendingModificationsCount()' );

## Apply the modifications
Koha::Borrower::Modifications->ApproveModifications('2');

## Test the counter
ok(
    Koha::Borrower::Modifications->GetPendingModificationsCount() == 0,
    'Test ApproveModifications() removes pending modification from db, again'
);

$new_borrower = GetMember( borrowernumber => '2' );

## Test to verify the borrower has been updated with the original values
ok(
    $new_borrower->{'surname'} eq $old_borrower->{'surname'},
    'Test ApproveModifications() applys modification to borrower, again'
);
