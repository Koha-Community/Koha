#!/usr/bin/perl

# Tests for SIP::ILS::Transaction
# Current state is very rudimentary. Please help to extend it!

use Modern::Perl;
use Test::More tests => 3;

use Koha::Database;
use t::lib::TestBuilder;
use C4::SIP::ILS::Patron;
use C4::SIP::ILS::Transaction::RenewAll;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $borr1 = $builder->build({ source => 'Borrower' });
my $card = $borr1->{cardnumber};
my $sip_patron = C4::SIP::ILS::Patron->new( $card );

# Create transaction RenewAll, assign patron, and run (no items)
my $transaction = C4::SIP::ILS::Transaction::RenewAll->new();
is( ref $transaction, "C4::SIP::ILS::Transaction::RenewAll", "New transaction created" );
is( $transaction->patron( $sip_patron ), $sip_patron, "Patron assigned to transaction" );
isnt( $transaction->do_renew_all, undef, "RenewAll on zero items" );

$schema->storage->txn_rollback;
