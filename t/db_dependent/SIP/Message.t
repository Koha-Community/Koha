#!/usr/bin/perl

# Tests for SIP::Sip::MsgType
# Please help to extend it!

# This file is part of Koha.
#
# Copyright 2016 Rijksmuseum
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
use Test::More tests => 16;
use Test::Exception;
use Test::MockObject;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Reserves qw( AddReserve );
use C4::Circulation qw( AddIssue AddReturn );
use Koha::Database;
use Koha::AuthUtils qw(hash_password);
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::CirculationRules;
use Koha::Items;
use Koha::Checkouts;
use Koha::Old::Checkouts;
use Koha::Patrons;
use Koha::Holds;

use C4::SIP::ILS;
use C4::SIP::ILS::Patron;
use C4::SIP::Sip qw(write_msg);
use C4::SIP::Sip::Constants qw(:all);
use C4::SIP::Sip::MsgType;

use constant PATRON_PW => 'do_not_ever_use_this_one';

# START testing
subtest 'Testing Patron Status Request V2' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 13;
    $C4::SIP::Sip::protocol_version = 2;
    test_request_patron_status_v2();
    $schema->storage->txn_rollback;
};

subtest 'Testing Patron Info Request V2' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 24;
    $C4::SIP::Sip::protocol_version = 2;
    test_request_patron_info_v2();
    $schema->storage->txn_rollback;
};

subtest 'Checkout V2' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 8;
    $C4::SIP::Sip::protocol_version = 2;
    test_checkout_v2();
    $schema->storage->txn_rollback;
};

subtest 'Test checkout desensitize' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 6;
    $C4::SIP::Sip::protocol_version = 2;
    test_checkout_desensitize();
    $schema->storage->txn_rollback;
};

subtest 'Test renew desensitize' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 6;
    $C4::SIP::Sip::protocol_version = 2;
    test_renew_desensitize();
    $schema->storage->txn_rollback;
};

subtest 'Checkin V2' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 40;
    $C4::SIP::Sip::protocol_version = 2;
    test_checkin_v2();
    $schema->storage->txn_rollback;
};

subtest 'Test hold_patron_bcode' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 2;
    $C4::SIP::Sip::protocol_version = 2;
    test_hold_patron_bcode();
    $schema->storage->txn_rollback;
};

subtest 'UseLocationAsAQInSIP syspref tests' => sub {
    plan tests => 2;

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new();

    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    t::lib::Mocks::mock_preference('UseLocationAsAQInSIP', 0);

     my $item = $builder->build_sample_item(
        {
            damaged       => 0,
            withdrawn     => 0,
            itemlost      => 0,
            restricted    => 0,
            homebranch    => $branchcode,
            holdingbranch => $branchcode,
            permanent_location => "PERMANENT_LOCATION"
        }
    );

    my $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    is( $sip_item->permanent_location, $branchcode, "When UseLocationAsAQInSIP is not set SIP item has permanent_location set to value of homebranch" );

    t::lib::Mocks::mock_preference('UseLocationAsAQInSIP', 1);

    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    is( $sip_item->permanent_location, "PERMANENT_LOCATION", "When UseLocationAsAQInSIP is set SIP item has permanent_location set to value of item permanent_location" );

    $schema->storage->txn_rollback;
};

subtest 'hold_patron_name() tests' => sub {

    plan tests => 3;

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new();

    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    my $item = $builder->build_sample_item(
        {
            damaged       => 0,
            withdrawn     => 0,
            itemlost      => 0,
            restricted    => 0,
            homebranch    => $branchcode,
            holdingbranch => $branchcode
        }
    );

    my $server = { ils => $mocks->{ils} };
    my $sip_item = C4::SIP::ILS::Item->new( $item->barcode );

    is( $sip_item->hold_patron_name, q{}, "SIP item with no hold returns empty string for patron name" );

    my $resp = C4::SIP::Sip::maybe_add( FID_CALL_NUMBER, $sip_item->hold_patron_name, $server );
    is( $resp, q{}, "maybe_add returns empty string for SIP item with no hold returns empty string" );

    $resp = C4::SIP::Sip::maybe_add( FID_CALL_NUMBER, "0", $server );
    is( $resp, q{CS0|}, "maybe_add will create the field of the string '0'" );

    $schema->storage->txn_rollback;
};

subtest 'Lastseen response' => sub {

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 6;
    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );
    my $seen_patron = $builder->build({
        source => 'Borrower',
        value  => {
            lastseen => '2001-01-01',
            password => hash_password( PATRON_PW ),
            branchcode => $branchcode,
        },
    });
    my $cardnum = $seen_patron->{cardnumber};
    my $sip_patron = C4::SIP::ILS::Patron->new( $cardnum );
    $findpatron = $sip_patron;

    my $siprequest = PATRON_INFO. 'engYYYYMMDDZZZZHHMMSS'.'Y         '.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $cardnum. '|'.
        FID_PATRON_PWD. PATRON_PW. '|';
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );

    my $server = { ils => $mocks->{ils} };
    undef $response;
    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '' );
    $msg->handle_patron_info( $server );

    isnt( $response, undef, 'At least we got a response.' );
    my $respcode = substr( $response, 0, 2 );
    is( $respcode, PATRON_INFO_RESP, 'Response code fine' );
    $seen_patron = Koha::Patrons->find({ cardnumber => $seen_patron->{cardnumber} });
    is( output_pref({str => $seen_patron->lastseen(), dateonly => 1}), output_pref({str => '2001-01-01', dateonly => 1}),'Last seen not updated if not tracking patrons');
    undef $response;
    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '1' );
    $msg->handle_patron_info( $server );

    isnt( $response, undef, 'At least we got a response.' );
    $respcode = substr( $response, 0, 2 );
    is( $respcode, PATRON_INFO_RESP, 'Response code fine' );
    $seen_patron = Koha::Patrons->find({ cardnumber => $seen_patron->cardnumber() });
    is( output_pref({str => $seen_patron->lastseen(), dateonly => 1}), output_pref({dt => dt_from_string(), dateonly => 1}),'Last seen updated if tracking patrons');
    $schema->storage->txn_rollback;

};

subtest "Test patron_status_string" => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 9;

    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value  => {
            branchcode => $branchcode,
        },
    });
    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );

    t::lib::Mocks::mock_userenv({ branchcode => $branchcode });

     my $item1 = $builder->build_sample_item(
        {
            damaged       => 0,
            withdrawn     => 0,
            itemlost      => 0,
            restricted    => 0,
            homebranch    => $branchcode,
            holdingbranch => $branchcode,
            permanent_location => "PERMANENT_LOCATION"
        }
    );
     AddIssue( $patron, $item1->barcode );

     my $item2 = $builder->build_sample_item(
        {
            damaged       => 0,
            withdrawn     => 0,
            itemlost      => 0,
            restricted    => 0,
            homebranch    => $branchcode,
            holdingbranch => $branchcode,
            permanent_location => "PERMANENT_LOCATION"
        }
    );
    AddIssue( $patron, $item2->barcode );

    is(
        Koha::Checkouts->search( { borrowernumber => $patron->borrowernumber } )->count, 2,
        "Found 2 checkouts for this patron"
    );

    $item1->itemlost(1)->store();
    $item2->itemlost(2)->store();

    is(
        Koha::Checkouts->search(
            { borrowernumber => $patron->borrowernumber, 'itemlost' => { '>', 0 } }, { join => 'item' }
        )->count,
        2,
        "Found 2 lost checkouts for this patron"
    );

    my $server->{account}->{lost_block_checkout} = undef;
    my $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{ }, "lost_block_checkout = 0 does not block checkouts with 2 lost checkouts" );;

    $server->{account}->{lost_block_checkout} = 0;
    $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{ }, "lost_block_checkout = 0 does not block checkouts with 2 lost checkouts" );;

    $server->{account}->{lost_block_checkout} = 1;
    $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{Y}, "lost_block_checkout = 1 does block checkouts with 2 lost checkouts" );;

    $server->{account}->{lost_block_checkout} = 2;
    $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{Y}, "lost_block_checkout = 2 does block checkouts with 2 lost checkouts" );;

    $server->{account}->{lost_block_checkout} = 3;
    $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{ }, "lost_block_checkout = 3 does not block checkouts with 2 lost checkouts" );;

    $server->{account}->{lost_block_checkout} = 2;
    $server->{account}->{lost_block_checkout_value} = 2;
    $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{ }, "lost_block_checkout = 2, lost_block_checkout_value = 2 does not block checkouts with 2 lost checkouts where only 1 has itemlost = 2" );

    $server->{account}->{lost_block_checkout} = 1;
    $server->{account}->{lost_block_checkout_value} = 2;
    $patron_status_string = C4::SIP::Sip::MsgType::patron_status_string( $sip_patron, $server );
    is( substr($patron_status_string, 9, 1), q{Y}, "lost_block_checkout = 2, lost_block_checkout_value = 2 does block checkouts with 2 lost checkouts where only 1 has itemlost = 2" );

    $schema->storage->txn_rollback;
};

subtest "Test build_additional_item_fields_string" => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 2;

    my $builder = t::lib::TestBuilder->new();

    my $item = $builder->build_sample_item;
    my $ils_item = C4::SIP::ILS::Item->new( $item->barcode );

    my $server = {};
    $server->{account}->{item_field}->{code} = 'itemnumber';
    $server->{account}->{item_field}->{field} = 'XY';
    my $attribute_string = $ils_item->build_additional_item_fields_string( $server );
    is( $attribute_string, "XY".$item->itemnumber."|", 'Attribute field generated correctly with single param' );

    $server = {};
    $server->{account}->{item_field}->[0]->{code} = 'itemnumber';
    $server->{account}->{item_field}->[0]->{field} = 'XY';
    $server->{account}->{item_field}->[1]->{code} = 'biblionumber';
    $server->{account}->{item_field}->[1]->{field} = 'YZ';
    $attribute_string = $ils_item->build_additional_item_fields_string( $server );
    is( $attribute_string, sprintf("XY%s|YZ%s|", $item->itemnumber, $item->biblionumber), 'Attribute field generated correctly with multiple params' );

    $schema->storage->txn_rollback;
};

subtest "Test build_custom_field_string" => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 2;

    my $builder = t::lib::TestBuilder->new();

    my $item = $builder->build_sample_item;
    my $item_id = $item->id;
    my $item_barcode = $item->barcode;
    my $ils_item = C4::SIP::ILS::Item->new( $item->barcode );

    my $server = {};
    $server->{account}->{custom_item_field}->{field} = "XY";
    $server->{account}->{custom_item_field}->{template} = "[% item.id %] [% item.barcode %], woo!";
    my $attribute_string = $ils_item->build_additional_item_fields_string( $server );
    is( $attribute_string, "XY$item_id $item_barcode, woo!|", 'Attribute field generated correctly with single param' );

    $server = {};
    $server->{account}->{custom_item_field}->[0]->{field} = "ZY";
    $server->{account}->{custom_item_field}->[0]->{template} = "[% item.id %]!";
    $server->{account}->{custom_item_field}->[1]->{field} = "ZX";
    $server->{account}->{custom_item_field}->[1]->{template} = "[% item.barcode %]*";
    $attribute_string = $ils_item->build_additional_item_fields_string( $server );
    is( $attribute_string, sprintf("ZY%s!|ZX%s*|", $item_id, $item_barcode), 'Attribute field generated correctly with multiple params' );

    $schema->storage->txn_rollback;
};

subtest "Test cr_item_field" => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 8;

    my $builder = t::lib::TestBuilder->new();
    my $branchcode  = $builder->build({ source => 'Branch' })->{branchcode};
    my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    # create some data
    my $patron1 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card1 = $patron1->{cardnumber};
    my $sip_patron1 = C4::SIP::ILS::Patron->new( $card1 );
    $findpatron = $sip_patron1;
    my $item_object = $builder->build_sample_item({
        damaged => 0,
        withdrawn => 0,
        itemlost => 0,
        restricted => 0,
        homebranch => $branchcode,
        holdingbranch => $branchcode,
        datelastseen => '1900-01-01',
    });

    my $mockILS = $mocks->{ils};
    my $server = { ils => $mockILS, account => {} };
    $mockILS->mock( 'institution', sub { $branchcode; } );
    $mockILS->mock( 'supports', sub { return; } );
    $mockILS->mock( 'checkin', sub {
        shift;
        return C4::SIP::ILS->checkin(@_);
    });
    my $today = dt_from_string;

    my $respcode;

    # Not checked out, toggle option checked_in_ok
    my $siprequest = CHECKIN . 'N' . 'YYYYMMDDZZZZHHMMSS' .
        siprequestdate( $today->clone->add( days => 1) ) .
        FID_INST_ID . $branchcode . '|'.
        FID_ITEM_ID . $item_object->barcode . '|' .
        FID_TERMINAL_PWD . 'ignored' . '|';
    undef $response;
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );

    $server->{account}->{cr_item_field} = 'itemnumber';

    $msg->handle_checkin( $server );

    my $id = $item_object->id;
    ok( $response =~ m/CR$id/, "Found correct CR field in response");

    $siprequest = ITEM_INFORMATION . 'YYYYMMDDZZZZHHMMSS' .
        FID_INST_ID . $branchcode . '|'.
        FID_ITEM_ID . $item_object->barcode . '|' .
        FID_TERMINAL_PWD . 'ignored' . '|';
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );

    $mockILS->mock( 'find_item', sub {
        return C4::SIP::ILS::Item->new( $item_object->barcode );
    });

    $server->{account}->{cr_item_field} = 'itype';

    $server->{account}->{seen_on_item_information} = '';
    $msg->handle_item_information( $server );
    $item_object->get_from_storage;
    my $stored_date = "1900-01-01 00:00:00";
    is( $item_object->datelastseen, $stored_date, "datelastseen remains unchanged" );

    $item_object->update({ itemlost => 1, datelastseen => '1900-01-01' });
    $server->{account}->{seen_on_item_information} = 'keep_lost';
    $msg->handle_item_information( $server );
    $item_object = Koha::Items->find( $item_object->id );
    isnt( $item_object->datelastseen, $stored_date, "datelastseen updated" );
    is( $item_object->itemlost, 1, "item remains lost" );

    $item_object->update({ itemlost => 1, datelastseen => '1900-01-01' });
    $server->{account}->{seen_on_item_information} = 'mark_found';
    $msg->handle_item_information( $server );
    $item_object = Koha::Items->find( $item_object->id );
    isnt( $item_object->datelastseen, $stored_date, "datelastseen updated" );
    is( $item_object->itemlost, 0, "item is no longer lost" );

    my $itype = $item_object->itype;
    ok( $response =~ m/CR$itype/, "Found correct CR field in response");

    $server->{account}->{format_due_date} = 1;
    t::lib::Mocks::mock_preference( 'dateFormat',  'sql' );
    my $issue = Koha::Checkout->new({ branchcode => $branchcode, borrowernumber => $patron1->{borrowernumber}, itemnumber => $item_object->itemnumber, date_due => "1999-01-01 12:59:00" })->store;
    $siprequest = ITEM_INFORMATION . 'YYYYMMDDZZZZHHMMSS' .
        FID_INST_ID . $branchcode . '|'.
        FID_ITEM_ID . $item_object->barcode . '|' .
        FID_TERMINAL_PWD . 'ignored' . '|';
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_item_information( $server );
    ok( $response =~ m/AH1999-01-01 12:59/, "Found correct CR field in response");

    $schema->storage->txn_rollback;
};

subtest 'Patron info summary > 5 should not crash server' => sub {

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 22;
    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );
    my $seen_patron = $builder->build({
        source => 'Borrower',
        value  => {
            lastseen => '2001-01-01',
            password => hash_password( PATRON_PW ),
            branchcode => $branchcode,
        },
    });
    my $cardnum = $seen_patron->{cardnumber};
    my $sip_patron = C4::SIP::ILS::Patron->new( $cardnum );
    $findpatron = $sip_patron;

    my @summaries = (
        '          ',
        'Y         ',
        ' Y        ',
        '  Y       ',
        '   Y      ',
        '    Y     ',
        '     Y    ',
        '      Y   ',
        '       Y  ',
        '        Y ',
        '         Y',
    );
    for my $summary ( @summaries ) {
        my $siprequest = PATRON_INFO . 'engYYYYMMDDZZZZHHMMSS' . $summary .
            FID_INST_ID . $branchcode . '|' .
            FID_PATRON_ID . $cardnum . '|' .
            FID_PATRON_PWD . PATRON_PW . '|';
        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );

        my $server = { ils => $mocks->{ils} };
        undef $response;
        $msg->handle_patron_info( $server );

        isnt( $response, undef, 'At least we got a response.' );
        my $respcode = substr( $response, 0, 2 );
        is( $respcode, PATRON_INFO_RESP, 'Response code fine' );
    }

    $schema->storage->txn_rollback;
};

subtest 'SC status tests' => sub {

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    plan tests => 2;

    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $sip_user = $builder->build_object({ class => "Koha::Patrons" });

    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );
    my $mockILS = $mocks->{ils};
    $mockILS->mock( 'checkout_ok', sub {1} );
    $mockILS->mock( 'checkin_ok', sub {1} );
    $mockILS->mock( 'status_update_ok', sub {1} );
    $mockILS->mock( 'offline_ok', sub {1} );
    $mockILS->mock( 'supports', sub {1} );
    my $server = Test::MockObject->new();
    $server->mock( 'get_timeout', sub {'100'});
    $server->{ils} = $mockILS;
    $server->{sip_username} = $sip_user->userid;
    $server->{account} = {};
    $server->{policy} = { renewal =>1,retries=>'000'};

    my $siprequest = SC_STATUS . '0' . '030' . '2.00';
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_sc_status( $server );

    like( $response, qr/98YYYYYY100000[0-9 ]{19}.00AO|BXYYYYYYYYYYYYYYYY|/, 'At least we got a response.' );

    $sip_user->delete;

    dies_ok { $msg->handle_sc_status( $server ) } "Dies if sip user cannot be found";

    $schema->storage->txn_rollback;
};

# Here is room for some more subtests

# END of main code

sub test_request_patron_status_v2 {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    my $patron1 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card1 = $patron1->{cardnumber};
    my $sip_patron1 = C4::SIP::ILS::Patron->new( $card1 );
    $findpatron = $sip_patron1;

    my $siprequest = PATRON_STATUS_REQ. 'engYYYYMMDDZZZZHHMMSS'.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $card1. '|'.
        FID_PATRON_PWD. PATRON_PW. '|';
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );

    my $server = { ils => $mocks->{ils} };
    undef $response;
    $msg->handle_patron_status( $server );

    isnt( $response, undef, 'At least we got a response.' );
    my $respcode = substr( $response, 0, 2 );
    is( $respcode, PATRON_STATUS_RESP, 'Response code fine' );

    check_field( $respcode, $response, FID_INST_ID, $branchcode , 'Verified institution id' );
    check_field( $respcode, $response, FID_PATRON_ID, $card1, 'Verified patron id' );
    check_field( $respcode, $response, FID_PERSONAL_NAME, $patron1->{surname}, 'Verified patron name', 'contains' );
    check_field( $respcode, $response, FID_VALID_PATRON, 'Y', 'Verified code BL' );
    check_field( $respcode, $response, FID_VALID_PATRON_PWD, 'Y', 'Verified code CQ' );
    check_field( $respcode, $response, FID_SCREEN_MSG, '.+', 'Verified non-empty screen message', 'regex' );

    # Now, we pass a wrong password and verify CQ again
    $siprequest = PATRON_STATUS_REQ. 'engYYYYMMDDZZZZHHMMSS'.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $card1. '|'.
        FID_PATRON_PWD. 'wrong_password'. '|';
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_status( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON_PWD, 'N', 'Verified code CQ for wrong pw' );

    # Check empty password and verify CQ again
    $siprequest = PATRON_STATUS_REQ. 'engYYYYMMDDZZZZHHMMSS'.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $card1. '|'.
        FID_PATRON_PWD. '|';
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_status( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON_PWD, 'N', 'code CQ should be N for empty AD' );

    # Finally, we send a wrong card number and check AE, BL
    # This is done by removing the new patron first
    Koha::Patrons->search({ cardnumber => $card1 })->delete;
    undef $findpatron;
    $siprequest = PATRON_STATUS_REQ. 'engYYYYMMDDZZZZHHMMSS'.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $card1. '|'.
        FID_PATRON_PWD. PATRON_PW. '|';
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_status( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON, 'N', 'Verified code BL for wrong cardnumber' );
    check_field( $respcode, $response, FID_PERSONAL_NAME, '', 'Name should be empty now' );
    check_field( $respcode, $response, FID_SCREEN_MSG, '.+', 'But we have a screen msg', 'regex' );
}

sub test_request_patron_info_v2 {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    my $patron2 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card = $patron2->{cardnumber};
    my $sip_patron2 = C4::SIP::ILS::Patron->new( $card );
    $findpatron = $sip_patron2;
    my $siprequest = PATRON_INFO. 'engYYYYMMDDZZZZHHMMSS'.'Y         '.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $card. '|'.
        FID_PATRON_PWD. PATRON_PW. '|';
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );

    my $server = { ils => $mocks->{ils} };
    undef $response;
    $msg->handle_patron_info( $server );
    isnt( $response, undef, 'At least we got a response.' );
    my $respcode = substr( $response, 0, 2 );
    is( $respcode, PATRON_INFO_RESP, 'Response code fine' );

    check_field( $respcode, $response, FID_INST_ID, $branchcode , 'Verified institution id' );
    check_field( $respcode, $response, FID_PATRON_ID, $card, 'Verified patron id' );
    check_field( $respcode, $response, FID_PERSONAL_NAME, $patron2->{surname}, 'Verified patron name', 'contains' );
    check_field( $respcode, $response, FID_VALID_PATRON, 'Y', 'Verified code BL' );
    check_field( $respcode, $response, FID_VALID_PATRON_PWD, 'Y', 'Verified code CQ' );
    check_field( $respcode, $response, FID_FEE_LMT, '.*', 'Checked existence of fee limit', 'regex' );
    check_field( $respcode, $response, FID_HOME_ADDR, $patron2->{address}, 'Address in BD', 'contains' );
    check_field( $respcode, $response, FID_EMAIL, $patron2->{email}, 'Verified email in BE' );
    check_field( $respcode, $response, FID_HOME_PHONE, $patron2->{phone}, 'Verified home phone in BF' );
    # No check for custom fields here (unofficial PB, PC and PI)
    check_field( $respcode, $response, FID_SCREEN_MSG, '.+', 'We have a screen msg', 'regex' );

    # Test customized patron name in AE with same sip request
    # This implicitly tests C4::SIP::ILS::Patron->name
    $server->{account}->{ae_field_template} = "X[% patron.surname %]Y";
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_info( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_PERSONAL_NAME, 'X' . $patron2->{surname} . 'Y', 'Check customized patron name' );

    undef $response;
    $server->{account}->{hide_fields} = "BD,BE,BF,PB";
    $msg->handle_patron_info( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_HOME_ADDR, undef, 'Home address successfully stripped from response' );
    check_field( $respcode, $response, FID_EMAIL, undef, 'Email address successfully stripped from response' );
    check_field( $respcode, $response, FID_HOME_PHONE, undef, 'Home phone successfully stripped from response' );
    check_field( $respcode, $response, FID_PATRON_BIRTHDATE, undef, 'Date of birth successfully stripped from response' );
    $server->{account}->{hide_fields} = "";

    # Check empty password and verify CQ again
    $siprequest = PATRON_INFO. 'engYYYYMMDDZZZZHHMMSS'.'Y         '.
        FID_INST_ID. $branchcode. '|'.
        FID_PATRON_ID. $card. '|'.
        FID_PATRON_PWD. '|';
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_info( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON_PWD, 'N', 'code CQ should be N for empty AD' );
    # Test empty password is OK if account configured to allow
    $server->{account}->{allow_empty_passwords} = 1;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_info( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON_PWD, 'Y', 'code CQ should be Y if empty AD allowed' );

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', '1' );
    my $patron = Koha::Patrons->find({ cardnumber => $card });
    $patron->update({ login_attempts => 0 });
    is( $patron->account_locked, 0, "Patron account not locked already" );
    $msg->handle_patron_info( $server );
    $patron = Koha::Patrons->find({ cardnumber => $card });
    is( $patron->account_locked, 0, "Patron account is not locked by patron info messages with empty password" );

    # Finally, we send a wrong card number
    Koha::Patrons->search({ cardnumber => $card })->delete;
    undef $findpatron;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_info( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON, 'N', 'Verified code BL for wrong cardnumber' );
    check_field( $respcode, $response, FID_PERSONAL_NAME, '', 'Name should be empty now' );
    check_field( $respcode, $response, FID_SCREEN_MSG, '.+', 'But we have a screen msg', 'regex' );
}

sub test_checkout_v2 {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode  = $builder->build({ source => 'Branch' })->{branchcode};
    my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );



    # create some data
    my $patron1 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card1 = $patron1->{cardnumber};
    my $sip_patron1 = C4::SIP::ILS::Patron->new( $card1 );
    $findpatron = $sip_patron1;
    my $item_object = $builder->build_sample_item({
        damaged => 0,
        withdrawn => 0,
        itemlost => 0,
        restricted => 0,
        homebranch => $branchcode,
        holdingbranch => $branchcode,
    });

    my $mockILS = $mocks->{ils};
    my $server = { ils => $mockILS, account => {} };
    $mockILS->mock( 'institution', sub { $branchcode; } );
    $mockILS->mock( 'supports', sub { return; } );
    $mockILS->mock( 'checkout', sub {
        shift;
        return C4::SIP::ILS->checkout(@_);
    });
    my $today = dt_from_string;
    t::lib::Mocks::mock_userenv({ branchcode => $branchcode, flags => 1 });
    t::lib::Mocks::mock_preference( 'CheckPrevCheckout',  'hardyes' );

    my $issue = Koha::Checkout->new({ branchcode => $branchcode, borrowernumber => $patron1->{borrowernumber}, itemnumber => $item_object->itemnumber })->store;
    my $return = AddReturn($item_object->barcode, $branchcode);

    my $siprequest = CHECKOUT . 'YN' . siprequestdate($today) .
    siprequestdate( $today->clone->add( days => 1) ) .
    FID_INST_ID . $branchcode . '|'.
    FID_PATRON_ID . $sip_patron1->id . '|' .
    FID_ITEM_ID . $item_object->barcode . '|' .
    FID_TERMINAL_PWD . 'ignored' . '|';
    undef $response;

    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $server->{account}->{prevcheckout_block_checkout} = 1;
    $msg->handle_checkout( $server );
    my $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'This item was previously checked out by you', 'Check screen msg', 'equals' );

    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 0, "Item was not checked out (prevcheckout_block_checkout enabled)");

    $server->{account}->{prevcheckout_block_checkout} = 0;
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 0, 2 );
    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 1, "Item was checked out (prevcheckout_block_checkout disabled)");

    $msg->handle_checkout( $server );
    ok( $response =~ m/AH\d{8}    \d{6}/, "Found AH field as timestamp in response");
    $server->{account}->{format_due_date} = 1;
    t::lib::Mocks::mock_preference( 'dateFormat',  'sql' );
    undef $response;
    $msg->handle_checkout( $server );
    ok( $response =~ m/AH\d{4}-\d{2}-\d{2}/, "Found AH field as SQL date in response");

    #returning item and now testing for blocked_item_types
    t::lib::Mocks::mock_preference( 'CheckPrevCheckout',  'hardno' );
    AddReturn($item_object->barcode, $branchcode);

    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $server->{account}->{blocked_item_types} = "CR|".$item_object->itype;
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'Item type cannot be checked out at this checkout location', 'Check screen msg', 'equals' );

    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 0, "Item was not checked out (item type matched blocked_item_types)");

    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $server->{account}->{blocked_item_types} = "";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 0, 2 );
    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 1, "Item was checked out successfully");

}

sub test_checkin_v2 {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode  = $builder->build({ source => 'Branch' })->{branchcode};
    my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    # create some data
    my $patron1 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card1 = $patron1->{cardnumber};
    my $sip_patron1 = C4::SIP::ILS::Patron->new( $card1 );
    $findpatron = $sip_patron1;
    my $item_object = $builder->build_sample_item({
        damaged => 0,
        withdrawn => 0,
        itemlost => 0,
        restricted => 0,
        homebranch => $branchcode,
        holdingbranch => $branchcode,
    });

    my $mockILS = $mocks->{ils};
    my $server = { ils => $mockILS, account => {} };
    $mockILS->mock( 'institution', sub { $branchcode; } );
    $mockILS->mock( 'supports', sub { return; } );
    $mockILS->mock( 'checkin', sub {
        shift;
        return C4::SIP::ILS->checkin(@_);
    });
    my $today = dt_from_string;

    # Checkin invalid barcode
    Koha::Items->search({ barcode => 'not_to_be_found' })->delete;
    my $siprequest = CHECKIN . 'N' . 'YYYYMMDDZZZZHHMMSS' .
        siprequestdate( $today->clone->add( days => 1) ) .
        FID_INST_ID . $branchcode . '|'.
        FID_ITEM_ID . 'not_to_be_found' . '|' .
        FID_TERMINAL_PWD . 'ignored' . '|';
    undef $response;
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    warnings_like { $msg->handle_checkin( $server ); }
        [ qr/No item 'not_to_be_found'/, qr/no item found in object to resensitize/ ],
        'Checkin of invalid item with two warnings';
    my $respcode = substr( $response, 0, 2 );
    is( $respcode, CHECKIN_RESP, 'Response code fine' );
    is( substr($response,2,1), '0', 'OK flag is false' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'Invalid Item', 'Check screen msg', 'regex' );
    check_field( $respcode, $response, FID_PERM_LOCN, '', 'Check that AQ is in the response' );

    # Not checked out, toggle option checked_in_ok
    $siprequest = CHECKIN . 'N' . 'YYYYMMDDZZZZHHMMSS' .
        siprequestdate( $today->clone->add( days => 1) ) .
        FID_INST_ID . $branchcode . '|'.
        FID_ITEM_ID . $item_object->barcode . '|' .
        FID_TERMINAL_PWD . 'ignored' . '|';
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    is( substr($response,2,1), '0', 'OK flag is false when checking in an item that was not checked out' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'not checked out', 'Check screen msg', 'regex' );
    # Toggle option
    $server->{account}->{checked_in_ok} = 1;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,2,1), '1', 'OK flag is true now with checked_in_ok flag set when checking in an item that was not checked out' );
    is( substr($response,5,1), 'N', 'Alert flag no longer set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, undef, 'No screen msg' );

    # Move item to another holding branch to trigger CV of 04 with alert flag
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    $item_object->holdingbranch( $branchcode2 )->store();
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,5,1), 'Y', 'Alert flag is set with check_in_ok, item is checked in but needs transfer' );
    check_field( $respcode, $response, FID_ALERT_TYPE, '04', 'Got FID_ALERT_TYPE (CV) field with value 04 ( needs transfer )' );
    $item_object->holdingbranch( $branchcode )->store();
    t::lib::Mocks::mock_preference( ' AllowReturnToBranch ', 'anywhere' );

    $server->{account}->{cv_send_00_on_success} = 0;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_ALERT_TYPE, undef, 'No FID_ALERT_TYPE (CV) field' );
    $server->{account}->{cv_send_00_on_success} = 1;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_ALERT_TYPE, '00', 'FID_ALERT_TYPE (CV) field is 00' );
    $server->{account}->{checked_in_ok} = 0;
    $server->{account}->{cv_send_00_on_success} = 0;

    t::lib::Mocks::mock_preference( 'RecordLocalUseOnReturn', '1' );
    $server->{account}->{checked_in_ok} = 0;
    $server->{account}->{cv_triggers_alert} = 0;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    is( substr( $response, 5, 1 ), 'Y', 'Checkin without CV triggers alert flag when cv_triggers_alert is off' );
    t::lib::Mocks::mock_preference( 'RecordLocalUseOnReturn', '0' );
    $server->{account}->{cv_triggers_alert} = 1;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    is( substr( $response, 5, 1 ), 'N', 'Checkin without CV does not trigger alert flag when cv_triggers_alert is on' );
    $server->{account}->{cv_triggers_alert} = 0;
    t::lib::Mocks::mock_preference( 'RecordLocalUseOnReturn', '1' );

    $server->{account}->{checked_in_ok} = 1;
    $server->{account}->{ct_always_send} = 0;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_DESTINATION_LOCATION, undef, 'No FID_DESTINATION_LOCATION (CT) field' );
    $server->{account}->{ct_always_send} = 1;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_DESTINATION_LOCATION, q{}, 'FID_DESTINATION_LOCATION (CT) field is empty but present' );
    $server->{account}->{checked_in_ok} = 0;
    $server->{account}->{ct_always_send} = 0;

    # Checkin at wrong branch: issue item and switch branch, and checkin
    my $issue = Koha::Checkout->new({ branchcode => $branchcode, borrowernumber => $patron1->{borrowernumber}, itemnumber => $item_object->itemnumber })->store;
    $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,2,1), '0', 'OK flag is false when we check in at the wrong branch and we do not allow it' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'Checkin failed', 'Check screen msg' );
    $branchcode = $item_object->homebranch;  # switch back
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );

    # Data corrupted: add same issue_id to old_issues
    Koha::Old::Checkout->new({ issue_id => $issue->issue_id })->store;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    warnings_like { $msg->handle_checkin( $server ); }
        [ qr/Duplicate entry/, qr/data issues/ ],
        'DBIx error on duplicate issue_id';
    is( substr($response,2,1), '0', 'OK flag is false when we encounter data corruption in old_issues' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'Checkin failed: data problem', 'Check screen msg' );

    # Finally checkin without problems (remove duplicate id)
    Koha::Old::Checkouts->search({ issue_id => $issue->issue_id })->delete;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,2,1), '1', 'OK flag is true when we checkin after removing the duplicate' );
    is( substr($response,5,1), 'N', 'Alert flag is not set' );
    is( Koha::Checkouts->find( $issue->issue_id ), undef,
        'Issue record is gone now' );

    # Test account option no_holds_check that prevents items on hold from being checked in via SIP
    $issue = Koha::Checkout->new({ branchcode => $branchcode, borrowernumber => $patron1->{borrowernumber}, itemnumber => $item_object->itemnumber })->store;
    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 1, "Item is checked out");
    Koha::Old::Checkouts->search({ issue_id => $issue->issue_id })->delete;
    $server->{account}->{holds_block_checkin} = 1;
    my $reserve_id = AddReserve({
        branchcode     => $branchcode,
        borrowernumber => $patron1->{borrowernumber},
        biblionumber   => $item_object->biblionumber,
        priority       => 1,
    });
    my $hold = Koha::Holds->find( $reserve_id );
    is( $hold->id, $reserve_id, "Hold was created successfully" );
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,2,1), '0', 'OK flag is false when we check in an item on hold and we do not allow it' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 1, "Item was not checked in");
    $hold->discard_changes;
    is( $hold->found, undef, "Hold was not marked as found by SIP when holds_block_checkin enabled");
    $server->{account}->{holds_block_checkin} = 0;

    # Test account option holds_get_captured that automatically sets the hold as found for a hold and possibly sets it to in transit
    $server->{account}->{holds_get_captured} = 0;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,2,1), '1', 'OK flag is true when we check in an item on hold and we allow it but do not capture it' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    is( Koha::Checkouts->search({ itemnumber => $item_object->id })->count, 0, "Item was checked in");
    $hold->discard_changes;
    is( $hold->found, undef, "Hold was not marked as found by SIP when holds_get_captured disabled");
    $hold->delete();
    $server->{account}->{holds_get_captured} = 1;
}

sub test_hold_patron_bcode {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode  = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    my $item = $builder->build_sample_item(
        {
            library => $branchcode
        }
    );

    my $server = { ils => $mocks->{ils} };
    my $sip_item = C4::SIP::ILS::Item->new( $item->barcode );

    is( $sip_item->hold_patron_bcode, q{}, "SIP item with no hold returns empty string" );

    my $resp = C4::SIP::Sip::maybe_add( FID_CALL_NUMBER, $sip_item->hold_patron_bcode, $server );
    is( $resp, q{}, "maybe_add returns empty string for SIP item with no hold returns empty string" );
}

sub test_checkout_desensitize {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode  = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    # create some data
    my $patron1 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card1 = $patron1->{cardnumber};
    my $sip_patron1 = C4::SIP::ILS::Patron->new( $card1 );
    my $patron_category = $sip_patron1->ptype();
    $findpatron = $sip_patron1;
    my $item_object = $builder->build_sample_item({
        damaged => 0,
        withdrawn => 0,
        itemlost => 0,
        restricted => 0,
        homebranch => $branchcode,
        holdingbranch => $branchcode,
    });
    my $itemtype = $item_object->effective_itemtype;

    my $mockILS = $mocks->{ils};
    my $server = { ils => $mockILS, account => {} };
    $mockILS->mock( 'institution', sub { $branchcode; } );
    $mockILS->mock( 'supports', sub { return; } );
    $mockILS->mock( 'checkout', sub {
        shift;
        return C4::SIP::ILS->checkout(@_);
    });
    my $today = dt_from_string;
    t::lib::Mocks::mock_userenv({ branchcode => $branchcode, flags => 1 });
    t::lib::Mocks::mock_preference( 'CheckPrevCheckout',  'hardyes' );

    my $siprequest = CHECKOUT . 'YN' . siprequestdate($today) .
    siprequestdate( $today->clone->add( days => 1) ) .
    FID_INST_ID . $branchcode . '|'.
    FID_PATRON_ID . $sip_patron1->id . '|' .
    FID_ITEM_ID . $item_object->barcode . '|' .
    FID_TERMINAL_PWD . 'ignored' . '|';

    undef $response;
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $server->{account}->{inhouse_patron_categories} = "A,$patron_category,Z";
    $msg->handle_checkout( $server );
    my $respcode = substr( $response, 5, 1 );
    is( $respcode, 'N', "Desensitize flag was not set for patron category in inhouse_patron_categories" );

    undef $response;
    $server->{account}->{inhouse_patron_categories} = "A,B,C";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for patron category not in inhouse_patron_categories" );

    undef $response;
    $server->{account}->{inhouse_patron_categories} = "";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for empty inhouse_patron_categories" );

    $server->{account}->{inhouse_patron_categories} = "";

    undef $response;
    $server->{account}->{inhouse_item_types} = "A,$itemtype,Z";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'N', "Desensitize flag was not set for itemtype in inhouse_item_types" );

    undef $response;
    $server->{account}->{inhouse_item_types} = "A,B,C";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for item type not in inhouse_item_types" );

    undef $response;
    $server->{account}->{inhouse_item_types} = "";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for empty inhouse_item_types" );
}

sub test_renew_desensitize {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode  = $builder->build({ source => 'Branch' })->{branchcode};
    my ( $response, $findpatron );
    my $mocks = create_mocks( \$response, \$findpatron, \$branchcode );

    # create some data
    my $patron1 = $builder->build({
        source => 'Borrower',
        value  => {
            password => hash_password( PATRON_PW ),
        },
    });
    my $card1 = $patron1->{cardnumber};
    my $sip_patron1 = C4::SIP::ILS::Patron->new( $card1 );
    my $patron_category = $sip_patron1->ptype();
    $findpatron = $sip_patron1;
    my $item_object = $builder->build_sample_item({
        damaged => 0,
        withdrawn => 0,
        itemlost => 0,
        restricted => 0,
        homebranch => $branchcode,
        holdingbranch => $branchcode,
    });
    my $itemtype = $item_object->effective_itemtype;

    my $mockILS = $mocks->{ils};
    my $server = { ils => $mockILS, account => {} };
    $mockILS->mock( 'institution', sub { $branchcode; } );
    $mockILS->mock( 'supports', sub { return; } );
    $mockILS->mock( 'checkout', sub {
        shift;
        return C4::SIP::ILS->checkout(@_);
    });
    my $today = dt_from_string;
    t::lib::Mocks::mock_userenv({ branchcode => $branchcode, flags => 1 });

    my $issue = Koha::Checkout->new({ branchcode => $branchcode, borrowernumber => $patron1->{borrowernumber}, itemnumber => $item_object->itemnumber })->store;

    my $siprequest = RENEW . 'YN' . siprequestdate($today) .
    siprequestdate( $today->clone->add( days => 1) ) .
    FID_INST_ID . $branchcode . '|'.
    FID_PATRON_ID . $sip_patron1->id . '|' .
    FID_ITEM_ID . $item_object->barcode . '|' .
    FID_TERMINAL_PWD . 'ignored' . '|';

    undef $response;
    my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $server->{account}->{inhouse_patron_categories} = "A,$patron_category,Z";
    $msg->handle_checkout( $server );
    my $respcode = substr( $response, 5, 1 );
    is( $respcode, 'N', "Desensitize flag was not set for patron category in inhouse_patron_categories" );

    undef $response;
    $server->{account}->{inhouse_patron_categories} = "A,B,C";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for patron category not in inhouse_patron_categories" );

    undef $response;
    $server->{account}->{inhouse_patron_categories} = "";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for empty inhouse_patron_categories" );

    $server->{account}->{inhouse_patron_categories} = "";

    undef $response;
    $server->{account}->{inhouse_item_types} = "A,B,C";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for item type not in inhouse_item_types" );

    undef $response;
    $server->{account}->{inhouse_item_types} = "";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'Y', "Desensitize flag was set for empty inhouse_item_types" );

    undef $response;
    $server->{account}->{inhouse_item_types} = "A,$itemtype,Z";
    $msg->handle_checkout( $server );
    $respcode = substr( $response, 5, 1 );
    is( $respcode, 'N', "Desensitize flag was not set for itemtype in inhouse_item_types" );

}

# Helper routines

sub create_mocks {
    my ( $response, $findpatron, $branchcode ) = @_; # referenced variables !

    # mock write_msg (imported from Sip.pm into Message.pm)
    my $mockMsg = Test::MockModule->new( 'C4::SIP::Sip::MsgType' );
    $mockMsg->mock( 'write_msg', sub { $$response = $_[1]; } ); # save response

    # mock ils object
    my $mockILS = Test::MockObject->new;
    $mockILS->mock( 'check_inst_id', sub {} );
    $mockILS->mock( 'institution_id', sub { $$branchcode; } );
    $mockILS->mock( 'find_patron', sub { $$findpatron; } );

    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rule_name    => 'renewalsallowed',
            rule_value   => '5',
        }
    );

    return { ils => $mockILS, message => $mockMsg };
}

sub check_field {
    my ( $code, $resp, $fld, $expr, $msg, $mode ) = @_;
    # mode: contains || equals || regex (by default: equals)

    # strip fixed part; prefix to simplify next regex
    $resp = '|'. substr( $resp, fixed_length( $code ) );
    my $fldval;
    if( $resp =~ /\|$fld([^\|]*)\|/ ) {
        $fldval = $1;
    } elsif( !defined($expr) ) { # field should not be found
        ok( 1, $msg );
        return;
    } else { # test fails
        is( 0, 1, "Code $fld not found in '$resp'?" );
        return;
    }

    if( !$mode || $mode eq 'equals' ) { # default
        is( $fldval, $expr, $msg );
    } elsif( $mode eq 'regex' ) {
        is( $fldval =~ /$expr/, 1, $msg );
    } else { # contains
        is( index( $fldval, $expr ) > -1, 1, $msg );
    }
}

sub siprequestdate {
    my ( $dt ) = @_;
    return $dt->ymd('').(' 'x4).$dt->hms('');
}

sub fixed_length { #length of fixed fields including response code
    return {
      ( PATRON_STATUS_RESP )  => 37,
      ( PATRON_INFO_RESP )    => 61,
      ( CHECKIN_RESP )        => 24,
      ( CHECKOUT_RESP )       => 24,
    }->{$_[0]};
}
