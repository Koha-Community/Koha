#!/usr/bin/perl

# Some tests for SIP::ILS::Patron
# This needs to be extended! Your help is appreciated..

use Modern::Perl;
use Test::More tests => 3;

use Koha::Database;
use t::lib::TestBuilder;
use t::lib::Mocks;
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

subtest "OverduesBlockCirc tests" => sub {

    plan tests => 6;

    my $odue_patron = $builder->build(
        {
            source => 'Borrower',
            value  => {
                dateexpiry    => "3000-01-01",
            }
        }
    );
    my $good_patron = $builder->build(
        {
            source => 'Borrower',
            value  => {
                dateexpiry    => "3000-01-01",
            }
        }
    );
    my $odue = $builder->build({ source => 'Issue', value => {
            borrowernumber => $odue_patron->{borrowernumber},
            date_due => '2017-01-01',
            }
    });
    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'noblock' );
    my $odue_sip_patron = C4::SIP::ILS::Patron->new( $odue_patron->{cardnumber} );
    is( $odue_sip_patron->{charge_ok}, 1, "Not blocked with overdues when set to 'Don't block'");
    $odue_sip_patron = C4::SIP::ILS::Patron->new( $good_patron->{cardnumber} );
    is( $odue_sip_patron->{charge_ok}, 1, "Not blocked without overdues when set to 'Don't block'");

    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'confirmation' );
    $odue_sip_patron = C4::SIP::ILS::Patron->new( $odue_patron->{cardnumber} );
    is( $odue_sip_patron->{charge_ok}, '', "Blocked with overdues when set to 'Ask for confirmation'");
    $odue_sip_patron = C4::SIP::ILS::Patron->new( $good_patron->{cardnumber} );
    is( $odue_sip_patron->{charge_ok}, 1, "Not blocked without overdues when set to 'confirmation'");

    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'block' );
    $odue_sip_patron = C4::SIP::ILS::Patron->new( $odue_patron->{cardnumber} );
    is( $odue_sip_patron->{charge_ok}, '', "Blocked with overdues when set to 'Block'");
    $odue_sip_patron = C4::SIP::ILS::Patron->new( $good_patron->{cardnumber} );
    is( $odue_sip_patron->{charge_ok}, 1, "Not blocked without overdues when set to 'Block'");

};

$schema->storage->txn_rollback;
