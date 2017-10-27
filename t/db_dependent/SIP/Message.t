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
use Test::More tests => 4;
use Test::MockObject;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::AuthUtils qw(hash_password);
use Koha::DateUtils;
use Koha::Items;
use Koha::Checkouts;
use Koha::Old::Checkouts;
use Koha::Patrons;

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
    plan tests => 18;
    $C4::SIP::Sip::protocol_version = 2;
    test_request_patron_info_v2();
    $schema->storage->txn_rollback;
};

subtest 'Checkin V2' => sub {
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;
    plan tests => 21;
    $C4::SIP::Sip::protocol_version = 2;
    test_checkin_v2();
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

sub test_checkin_v2 {
    my $builder = t::lib::TestBuilder->new();
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
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
    my $item = $builder->build({
        source => 'Item',
        value => { damaged => 0, withdrawn => 0, itemlost => 0, restricted => 0, homebranch => $branchcode, holdingbranch => $branchcode },
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

    # Not checked out, toggle option checked_in_ok
    $siprequest = CHECKIN . 'N' . 'YYYYMMDDZZZZHHMMSS' .
        siprequestdate( $today->clone->add( days => 1) ) .
        FID_INST_ID . $branchcode . '|'.
        FID_ITEM_ID . $item->{barcode} . '|' .
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
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, undef, 'No screen msg' );
    $server->{account}->{checked_in_ok} = 0;

    # Checkin at wrong branch: issue item and switch branch, and checkin
    my $issue = Koha::Checkout->new({ branchcode => $branchcode, borrowernumber => $patron1->{borrowernumber}, itemnumber => $item->{itemnumber} })->store;
    $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    $msg->handle_checkin( $server );
    is( substr($response,2,1), '0', 'OK flag is false when we check in at the wrong branch and we do not allow it' );
    is( substr($response,5,1), 'Y', 'Alert flag is set' );
    check_field( $respcode, $response, FID_SCREEN_MSG, 'Checkin failed', 'Check screen msg' );
    $branchcode = $item->{homebranch};  # switch back
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );

    # Data corrupted: add same issue_id to old_issues
    Koha::Old::Checkout->new({ issue_id => $issue->issue_id })->store;
    undef $response;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    warnings_like { $msg->handle_checkin( $server ); }
        [ qr/Duplicate entry/, qr/data corrupted/ ],
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
    }->{$_[0]};
}
