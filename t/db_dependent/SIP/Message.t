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
use Test::More tests => 2;
use Test::MockObject;
use Test::MockModule;

use Koha::Database;
use t::lib::TestBuilder;
use Koha::AuthUtils qw(hash_password);

use C4::SIP::ILS::Patron;
use C4::SIP::Sip qw(write_msg);
use C4::SIP::Sip::Constants qw(:all);
use C4::SIP::Sip::MsgType;

use constant PATRON_PW => 'do_not_ever_use_this_one';

my $fixed_length = { #length of fixed fields including response code
    ( PATRON_STATUS_RESP ) => 37,
    ( PATRON_INFO_RESP )   => 61,
};

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

# COMMON: Some common stuff for all/most subtests
my ( $response, $findpatron, $branch, $branchcode );
# mock write_msg (imported from Sip.pm into Message.pm)
my $mockMsg = Test::MockModule->new( 'C4::SIP::Sip::MsgType' );
$mockMsg->mock( 'write_msg', sub { $response = $_[1]; } ); # save response
# mock ils object
my $mockILS = Test::MockObject->new;
$mockILS->mock( 'check_inst_id', sub {} );
$mockILS->mock( 'institution_id', sub { $branchcode; } );
$mockILS->mock( 'find_patron', sub { $findpatron; } );
$branch = $builder->build({
    source => 'Branch',
});
$branchcode = $branch->{branchcode};

# START testing
subtest 'Testing Patron Status Request V2' => sub {
    $schema->storage->txn_begin;
    plan tests => 13;
    $C4::SIP::Sip::protocol_version = 2;
    test_request_patron_status_v2();
    $schema->storage->txn_rollback;
};

subtest 'Testing Patron Info Request V2' => sub {
    $schema->storage->txn_begin;
    plan tests => 16;
    $C4::SIP::Sip::protocol_version = 2;
    test_request_patron_info_v2();
    $schema->storage->txn_rollback;
};

# Here is room for some more subtests

# END of main code

sub test_request_patron_status_v2 {
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

    my $server = { ils => $mockILS };
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
    $schema->resultset('Borrower')->search({ cardnumber => $card1 })->delete;
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

    my $server = { ils => $mockILS };
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

    # Finally, we send a wrong card number
    $schema->resultset('Borrower')->search({ cardnumber => $card })->delete;
    undef $findpatron;
    $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
    undef $response;
    $msg->handle_patron_info( $server );
    $respcode = substr( $response, 0, 2 );
    check_field( $respcode, $response, FID_VALID_PATRON, 'N', 'Verified code BL for wrong cardnumber' );
    check_field( $respcode, $response, FID_PERSONAL_NAME, '', 'Name should be empty now' );
    check_field( $respcode, $response, FID_SCREEN_MSG, '.+', 'But we have a screen msg', 'regex' );
}

# Helper routines

sub check_field {
    my ( $code, $resp, $fld, $expr, $msg, $mode ) = @_;
    # mode: contains || equals || regex (by default: equals)

    # strip fixed part; prefix to simplify next regex
    $resp = '|'. substr( $resp, $fixed_length->{$code} );
    my $fldval;
    if( $resp =~ /\|$fld([^\|]*)\|/ ) {
        $fldval = $1;
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
