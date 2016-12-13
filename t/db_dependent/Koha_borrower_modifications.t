#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 11;
use Test::Exception;

use t::lib::TestBuilder;

use String::Random qw( random_string );
use Try::Tiny;

use C4::Context;
use C4::Members;

BEGIN {
    use_ok('Koha::Patron::Modification');
    use_ok('Koha::Patron::Modifications');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;


subtest 'store( extended_attributes ) tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    Koha::Patron::Modifications->search->delete;

    my $patron
        = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $verification_token = random_string("..........");
    my $valid_json_text    = '[{"code":"CODE","value":"VALUE"}]';
    my $invalid_json_text  = '[{';

    Koha::Patron::Modification->new(
        {   verification_token  => $verification_token,
            borrowernumber      => $patron,
            surname             => 'Hall',
            extended_attributes => $valid_json_text
        }
    )->store();

    my $patron_modification
        = Koha::Patron::Modifications->search( { borrowernumber => $patron } )
        ->next;

    is( $patron_modification->surname,
        'Hall', 'Patron modification correctly stored with valid JSON data' );
    is( $patron_modification->extended_attributes,
        $valid_json_text,
        'Patron modification correctly stored with valid JSON data' );

    $verification_token = random_string("..........");
    throws_ok {
        Koha::Patron::Modification->new(
            {   verification_token  => $verification_token,
                borrowernumber      => $patron,
                surname             => 'Hall',
                extended_attributes => $invalid_json_text
            }
        )->store();
    }
    'Koha::Exceptions::Patron::Modification::InvalidData',
        'Trying to store invalid JSON in extended_attributes field raises exception';

    is( $@, 'The passed extended_attributes is not valid JSON' );

    $schema->storage->txn_rollback;
};


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
    ok( $_->isa('Koha::Exceptions::Patron::Modification::DuplicateVerificationToken'),
        'Attempting to add a duplicate verification token to the database should raise a Koha::Exceptions::Koha::Patron::Modification::DuplicateVerificationToken exception' );
    is( $_->message, "Duplicate verification token 1234567890", 'Exception carries the right message' );
};

## Get the new pending modification
my $borrower =
  Koha::Patron::Modifications->find( { verification_token => '1234567890' } );

## Verify we get the same data
is( $borrower->surname, 'Hall', 'Found modification has matching surname' );

## Create new pending modification for a patron
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

$schema->storage->txn_rollback;

1;
