#!/usr/bin/perl

# Some tests for SIP::ILS::Patron
# This needs to be extended! Your help is appreciated..

use Modern::Perl;
use Test::More tests => 10;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::SIP::ILS::Patron;
use Koha::Account::Lines;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Patron::Attributes;
use Koha::Patrons;

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

subtest "new tests" => sub {

    plan tests => 5;

    my $patron = $builder->build(
        {
            source => 'Borrower'
        }
    );

    my $cardnumber      = $patron->{cardnumber};
    my $userid         = $patron->{userid};
    my $borrowernumber = $patron->{borrowernumber};

    my $ils_patron = C4::SIP::ILS::Patron->new($cardnumber);
    is( ref($ils_patron), 'C4::SIP::ILS::Patron', 'Found patron via cardnumber scalar' );
    $ils_patron = C4::SIP::ILS::Patron->new($userid);
    is( ref($ils_patron), 'C4::SIP::ILS::Patron', 'Found patron via userid scalar' );
    $ils_patron = C4::SIP::ILS::Patron->new( { borrowernumber => $borrowernumber } );
    is( ref($ils_patron), 'C4::SIP::ILS::Patron', 'Found patron via borrowernumber hashref' );
    $ils_patron = C4::SIP::ILS::Patron->new( { cardnumber => $cardnumber } );
    is( ref($ils_patron), 'C4::SIP::ILS::Patron', 'Found patron via cardnumber hashref' );
    $ils_patron = C4::SIP::ILS::Patron->new( { userid => $userid } );
    is( ref($ils_patron), 'C4::SIP::ILS::Patron', 'Found patron via userid hashref' );
};

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

subtest "Test build_custom_field_string" => sub {

    plan tests => 5;

    my $patron = $builder->build_object( { class => 'Koha::Patrons',value=>{surname => "Duck", firstname => "Darkwing"} } );


    my $ils_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );

    my $server = {};
    $server->{account}->{custom_patron_field}->{field} = "DW";
    my $attribute_string = $ils_patron->build_custom_field_string( $server );
    is( $attribute_string, "", 'Custom field not generated if no value passed' );

    $server = {};
    $server->{account}->{custom_patron_field}->{template} = "[% patron.surname %]";
    $attribute_string = $ils_patron->build_custom_field_string( $server );
    is( $attribute_string, "", 'Custom field not generated if no field passed' );


    $server = {};
    $server->{account}->{custom_patron_field}->{field} = "DW";
    $server->{account}->{custom_patron_field}->{template} = "[% patron.firstname %] [% patron.surname %], let's get dangerous!";
    $attribute_string = $ils_patron->build_custom_field_string( $server );
    is( $attribute_string, "DWDarkwing Duck, let's get dangerous!|", 'Custom field processed correctly' );

    $server = {};
    $server->{account}->{custom_patron_field}->[0]->{field} = "DW";
    $server->{account}->{custom_patron_field}->[0]->{template} = "[% patron.firstname %] [% patron.surname %], let's get dangerous!";
    $server->{account}->{custom_patron_field}->[1]->{field} = "LM";
    $server->{account}->{custom_patron_field}->[1]->{template} = "Launchpad McQuack crashed on [% patron.dateexpiry %]";
    $attribute_string = $ils_patron->build_custom_field_string( $server );
    is( $attribute_string, "DWDarkwing Duck, let's get dangerous!|LMLaunchpad McQuack crashed on ".$patron->dateexpiry."|", 'Custom fields processed correctly when multiple exist' );

    $server = {};
    $server->{account}->{custom_patron_field}->[0]->{field} = "DW";
    $server->{account}->{custom_patron_field}->[0]->{template} = "[% IF (patron.firstname) %] patron.surname, let's get dangerous!";
    $server->{account}->{custom_patron_field}->[1]->{field} = "LM";
    $server->{account}->{custom_patron_field}->[1]->{template} = "Launchpad McQuack crashed on [% patron.dateexpiry %]";
    $attribute_string = $ils_patron->build_custom_field_string( $server );
    is( $attribute_string, "LMLaunchpad McQuack crashed on ".$patron->dateexpiry."|", 'Custom fields processed correctly, bad template generate no text' );

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

subtest "fine_items tests" => sub {

    plan tests => 12;

    my $patron = $builder->build(
        {
            source => 'Borrower',
        }
    );

    my $fee1 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                amountoutstanding => 1,
            }
        }
    );

    my $fee2 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                amountoutstanding => 1,
            }
        }
    );

    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->{cardnumber} );

    my $all_fine_items = $sip_patron->fine_items;
    is( @$all_fine_items, 2, "Got all fine items" );

    # Should return only the first fine item
    my $fine_items = $sip_patron->fine_items(1,1);
    is( @$fine_items, 1, "Got one fine item" );
    is( $fine_items->[0]->{barcode}, $all_fine_items->[0]->{barcode}, "Got correct fine item");

    # Should return only the second fine item
    $fine_items = $sip_patron->fine_items(2,2);
    is( @$fine_items, 1, "Got one fine item" );
    is( $fine_items->[0]->{barcode}, $all_fine_items->[1]->{barcode}, "Got correct fine item");

    # Should return all fine items
    $fine_items = $sip_patron->fine_items(1,2);
    is( @$fine_items, 2, "Got two fine items" );
    is( $fine_items->[0]->{barcode}, $all_fine_items->[0]->{barcode}, "Got correct first fine item");
    is( $fine_items->[1]->{barcode}, $all_fine_items->[1]->{barcode}, "Got correct second fine item");

    # Check an invalid end boundary
    $fine_items = $sip_patron->fine_items(1,99);
    is( @$fine_items, 2, "Got two fine items" );
    is( $fine_items->[0]->{barcode}, $all_fine_items->[0]->{barcode}, "Got correct first fine item");
    is( $fine_items->[1]->{barcode}, $all_fine_items->[1]->{barcode}, "Got correct second fine item");

    # Check an invalid start boundary
    $fine_items = $sip_patron->fine_items(98,99);
    is( @$fine_items, 0, "Got zero fine items" );
};

$schema->storage->txn_rollback;

subtest "NoIssuesChargeGuarantees tests" => sub {

    plan tests => 6;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'parent' );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $child  = $builder->build_object({ class => 'Koha::Patrons' });
    my $sibling  = $builder->build_object({ class => 'Koha::Patrons' });
    $child->add_guarantor({ guarantor_id => $patron->borrowernumber, relationship => 'parent' });
    $sibling->add_guarantor({ guarantor_id => $patron->borrowernumber, relationship => 'parent' });

    t::lib::Mocks::mock_preference('noissuescharge', 50);
    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantees', 11.01);
    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantorsWithGuarantees', undef);

    my $fee1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value  => {
                borrowernumber => $patron->borrowernumber,
                amountoutstanding => 11,
                debit_type_code   => 'OVERDUE',
            }
        }
    )->store;

    my $fee2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value  => {
                borrowernumber => $child->borrowernumber,
                amountoutstanding => 0.11,
                debit_type_code   => 'OVERDUE',
            }
        }
    )->store;

    my $fee3 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value  => {
                borrowernumber => $sibling->borrowernumber,
                amountoutstanding => 11.11,
                debit_type_code   => 'OVERDUE',
            }
        }
    )->store;

    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );

    is( $sip_patron->fines_amount, 11, "Only patron's fines are reported in total");
    ok( !$sip_patron->charge_ok, "Guarantor blocked");
    like( $sip_patron->screen_msg, qr/Patron blocked by fines \(22\.22\) on guaranteed accounts/,"Screen message includes related fines total");

    $sip_patron = C4::SIP::ILS::Patron->new( $child->cardnumber );

    is( $sip_patron->fines_amount, 0.11,"Guarantee only fines correctly counted");
    ok( $sip_patron->charge_ok, "Guarantee not blocked by guarantor fines");
    unlike( $sip_patron->screen_msg, qr/Patron blocked by fines .* on guaranteed accounts/,"Screen message does not include blocked message");

    $schema->storage->txn_rollback;
};

subtest "NoIssuesChargeGuarantorsWithGuarantees tests" => sub {

    plan tests => 12;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'parent' );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $child  = $builder->build_object({ class => 'Koha::Patrons' });
    $child->add_guarantor({ guarantor_id => $patron->borrowernumber, relationship => 'parent' });

    t::lib::Mocks::mock_preference('noissuescharge', 50);
    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantorsWithGuarantees', 11.01);

    my $fee1 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value  => {
                borrowernumber => $patron->borrowernumber,
                amountoutstanding => 11,
                debit_type_code   => 'OVERDUE',
            }
        }
    )->store;

    my $fee2 = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value  => {
                borrowernumber => $child->borrowernumber,
                amountoutstanding => 0.11,
                debit_type_code   => 'OVERDUE',
            }
        }
    )->store;

    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );

    is( $sip_patron->fines_amount, 11, "Personal fines correctly reported");
    ok( !$sip_patron->charge_ok, "Guarantor blocked");
    like( $sip_patron->screen_msg, qr/Patron blocked by fines \(11\.11\) on related accounts/,"Screen message includes related fines total");

    $sip_patron = C4::SIP::ILS::Patron->new( $child->cardnumber );

    is( $sip_patron->fines_amount, 0.11, "Personal fines correctly reported");
    ok( !$sip_patron->charge_ok, "Guarantee blocked");
    like( $sip_patron->screen_msg, qr/Patron blocked by fines \(11\.11\) on related accounts/,"Screen message includes related fines total");

    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantorsWithGuarantees', 12.01);

    $sip_patron = C4::SIP::ILS::Patron->new( $child->cardnumber );

    is( $sip_patron->fines_amount, 0.11, "Personal fines correctly reported");
    ok( $sip_patron->charge_ok, "Guarantee not blocked");
    unlike( $sip_patron->screen_msg, qr/Patron blocked by fines .* on related accounts/,"Screen message does not indicate block");

    $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );

    is( $sip_patron->fines_amount, 11, "Personal fines correctly reported");
    ok( $sip_patron->charge_ok, "Patron not blocked");
    unlike( $sip_patron->screen_msg, qr/Patron blocked by fines .* on related accounts/,"Screen message does not indicate block");

    $schema->storage->txn_rollback;
};
