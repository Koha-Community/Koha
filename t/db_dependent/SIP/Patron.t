#!/usr/bin/perl

# Some tests for SIP::ILS::Patron
# This needs to be extended! Your help is appreciated..

use Modern::Perl;
use Test::More tests => 2;

use Koha::Database;
use t::lib::TestBuilder;
use C4::SIP::ILS::Patron;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $patron1 = $builder->build({ source => 'Borrower' });
my $card = $patron1->{cardnumber};

# Check existing card number
my $sip_patron = C4::SIP::ILS::Patron->new( $card );
is( defined $sip_patron, 1, "Patron is valid" );

# Check invalid cardnumber by deleting patron
$schema->resultset('Borrower')->search({ cardnumber => $card })->delete;
my $sip_patron2 = C4::SIP::ILS::Patron->new( $card );
is( $sip_patron2, undef, "Patron is not valid (anymore)" );

$schema->storage->txn_rollback;
