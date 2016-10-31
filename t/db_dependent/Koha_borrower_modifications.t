#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 9;
use Try::Tiny;

use t::lib::TestBuilder;

use C4::Context;
use C4::Members;

BEGIN {
    use_ok('Koha::Patron::Modification');
    use_ok('Koha::Patron::Modifications');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->do("DELETE FROM borrower_modifications");

## Create new pending modification
Koha::Patron::Modification->new(
    {
        verification_token => '1234567890',
        surname            => 'Hall',
        firstname          => 'Kyle'
    }
)->store();

## Ensure duplicate verification tokens cannot be added to the database
try {
    Koha::Patron::Modification->new(
        {
            verification_token => '1234567890',
            surname            => 'Hall',
            firstname          => 'Daria'
        }
    )->store();
} catch {
    ok( $_->isa('Koha::Exceptions::Koha::Patron::Modification::DuplicateVerificationToken'),
        'Attempting to add a duplicate verification token to the database should raise a Koha::Exceptions::Koha::Patron::Modification::DuplicateVerificationToken exception' );
};

## Get the new pending modification
my $borrower =
  Koha::Patron::Modifications->find( { verification_token => '1234567890' } );

## Verify we get the same data
is( $borrower->surname, 'Hall', 'Found modification has matching surname' );

## Create new pending modification for a patron
my $builder = t::lib::TestBuilder->new;
my $borr1 = $builder->build( { source => 'Borrower' } )->{borrowernumber};

my $m1 = Koha::Patron::Modification->new(
    {
        borrowernumber => $borr1,
        surname        => 'Hall',
        firstname      => 'Kyle'
    }
)->store();

## Test the counter
is( Koha::Patron::Modifications->pending_count,
    1, 'Test pending_count()' );

## Create new pending modification for another patron
my $borr2 = $builder->build( { source => 'Borrower' } )->{borrowernumber};
my $m2 = Koha::Patron::Modification->new(
    {
        borrowernumber => $borr2,
        surname        => 'Smith',
        firstname      => 'Sandy'
    }
)->store();

## Test the counter
is(
    Koha::Patron::Modifications->pending_count(), 2,
'Add a new pending modification and test pending_count() again'
);

## Check GetPendingModifications
my $pendings = Koha::Patron::Modifications->pending;
my @firstnames_mod =
  sort ( $pendings->[0]->{firstname}, $pendings->[1]->{firstname} );
ok( $firstnames_mod[0] eq 'Kyle',  'Test pending()' );
ok( $firstnames_mod[1] eq 'Sandy', 'Test pending() again' );

## This should delete the row from the table
$m2->delete();

## Save a copy of the borrowers original data
my $old_borrower = GetMember( borrowernumber => $borr1 );

## Apply the modifications
$m1->approve();

## Get a copy of the borrowers current data
my $new_borrower = GetMember( borrowernumber => $borr1 );

## Check to see that the approved modifications were saved
ok( $new_borrower->{'surname'} eq 'Hall',
    'Test approve() applies modification to borrower' );

$dbh->rollback();
