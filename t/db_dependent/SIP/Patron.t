#!/usr/bin/perl

# Some tests for SIP::ILS::Patron
# This needs to be extended! Your help is appreciated..

use Modern::Perl;
use Test::More tests => 5;

use Koha::Database;
use Koha::Patrons;
use Koha::DateUtils;
use t::lib::TestBuilder;
use t::lib::Mocks;
use C4::SIP::ILS::Patron;
use Koha::Patron::Attributes;

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

subtest "Test build_patron_attribute_string" => sub {

    plan tests => 2;

    my $patron = $builder->build( { source => 'Borrower' } );

    my $attribute_type = $builder->build( { source => 'BorrowerAttributeType' } );
    my $attribute = Koha::Patron::Attribute->new(
        {
            borrowernumber => $patron->{borrowernumber},
            code           => $attribute_type->{code},
            attribute      => 'Test Attribute'
        }
    )->store();

    my $attribute_type2 = $builder->build( { source => 'BorrowerAttributeType' } );
    my $attribute2 = Koha::Patron::Attribute->new(
        {
            borrowernumber => $patron->{borrowernumber},
            code           => $attribute_type2->{code},
            attribute      => 'Another Test Attribute'
        }
    )->store();

    my $ils_patron = C4::SIP::ILS::Patron->new( $patron->{cardnumber} );

    my $server = {};
    $server->{account}->{patron_attribute}->{code} = $attribute->code;
    $server->{account}->{patron_attribute}->{field} = 'XY';
    my $attribute_string = $ils_patron->build_patron_attributes_string( $server );
    is( $attribute_string, "XYTest Attribute|", 'Attribute field generated correctly with single param' );

    $server = {};
    $server->{account}->{patron_attribute}->[0]->{code} = $attribute->code;
    $server->{account}->{patron_attribute}->[0]->{field} = 'XY';
    $server->{account}->{patron_attribute}->[1]->{code} = $attribute2->code;
    $server->{account}->{patron_attribute}->[1]->{field} = 'YZ';
    $attribute_string = $ils_patron->build_patron_attributes_string( $server );
    is( $attribute_string, "XYTest Attribute|YZAnother Test Attribute|", 'Attribute field generated correctly with multiple params' );
};

subtest "update_lastseen tests" => sub {
    plan tests => 2;

    my $seen_patron = $builder->build(
        {
            source => 'Borrower',
            value  => {
                lastseen    => "2001-01-01",
            }
        }
    );
    my $sip_patron = C4::SIP::ILS::Patron->new( $seen_patron->{cardnumber} );
    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '' );
    $sip_patron->update_lastseen();
    $seen_patron = Koha::Patrons->find({ cardnumber => $seen_patron->{cardnumber} });
    is( output_pref({str => $seen_patron->lastseen(), dateonly => 1}), output_pref({str => '2001-01-01', dateonly => 1}),'Last seen not updated if not tracking patrons');
    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '1' );
    $sip_patron->update_lastseen();
    $seen_patron = Koha::Patrons->find({ cardnumber => $seen_patron->cardnumber() });
    is( output_pref({str => $seen_patron->lastseen(), dateonly => 1}), output_pref({dt => dt_from_string(), dateonly => 1}),'Last seen updated to today if tracking patrons');
};

$schema->storage->txn_rollback;
