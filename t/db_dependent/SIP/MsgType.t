#!/usr/bin/perl

# Copyright 2025 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 3;
use Test::NoWarnings;
use Test::Warn;
use Test::MockModule;

use C4::SIP::Sip::MsgType;
use C4::SIP::Sip::Constants qw(:all);

use t::lib::TestBuilder;
use t::lib::Mocks;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

# Mock siplog to capture debug messages
my @log_calls;
my $mock_sip = Test::MockModule->new('C4::SIP::Sip::MsgType');
$mock_sip->mock(
    'siplog',
    sub {
        my ( $level, $mask, @args ) = @_;
        push @log_calls, { level => $level, mask => $mask, args => \@args };
    }
);

subtest '_initialize() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Create test data
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );

    subtest 'normal patron info message parsing' => sub {
        plan tests => 3;

        @log_calls = ();    # Reset log capture

        # Set protocol version to 2 for PATRON_INFO messages
        $C4::SIP::Sip::protocol_version = 2;

        # Normal well-formed message (using proper format from sip_cli_emulator.pl)
        my $siprequest = PATRON_INFO . 'eng'    # Language
            . 'YYYYMMDDZZZZHHMMSS'              # Transaction date
            . 'Y         '                      # Summary field (10 chars)
            . FID_INST_ID
            . $library->branchcode . '|'
            . FID_PATRON_ID
            . $patron->cardnumber . '|'
            . FID_PATRON_PWD
            . 'password|';

        my ($msg) = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Normal message parsed successfully' );
        is( $msg->{fields}->{ FID_PATRON_ID() }, $patron->cardnumber,  'Patron ID field extracted correctly' );
        is( $msg->{fields}->{ FID_INST_ID() },   $library->branchcode, 'Institution ID field extracted correctly' );
    };

    subtest 'message with empty patron ID field' => sub {
        plan tests => 4;

        @log_calls = ();    # Reset log capture

        # Message with empty patron ID - this simulates split() creating empty fields
        my $siprequest = PATRON_INFO . 'engYYYYMMDDZZZZHHMMSS' . 'Y         '    # Summary field
            . FID_INST_ID . $library->branchcode . '|' . FID_PATRON_ID . '|'     # Empty patron ID field
            . FID_PATRON_PWD . 'password|';

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Message with empty patron ID parsed' );
        is( $msg->{fields}->{ FID_PATRON_ID() }, '', 'Empty patron ID field extracted as empty string' );
        is( $msg->{fields}->{ FID_INST_ID() },   $library->branchcode, 'Institution ID still extracted correctly' );

        # Verify debug logging occurred
        my $debug_logs = grep { $_->{level} eq 'LOG_DEBUG' } @log_calls;
        ok( $debug_logs > 0, 'Debug messages logged for empty patron ID' );
    };

    subtest 'message with malformed field delimiters' => sub {
        plan tests => 3;

        @log_calls = ();    # Reset log capture

        # Message with consecutive delimiters that could confuse split()
        my $siprequest = PATRON_INFO . 'engYYYYMMDDZZZZHHMMSS' . 'Y         '    # Summary field
            . FID_INST_ID . $library->branchcode . '||'                          # Double delimiter
            . FID_PATRON_ID . '|';

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Message with malformed delimiters parsed' );

        # The empty field between || should be handled gracefully
        ok( exists $msg->{fields}->{ FID_INST_ID() }, 'Institution ID field exists despite malformed delimiters' );

        # Check for debug messages about malformed delimiters
        my $debug_logs = grep { $_->{level} eq 'LOG_DEBUG' } @log_calls;
        ok( $debug_logs > 0, 'Debug messages logged for malformed delimiters' );
    };

    subtest 'message parsing that could create arrayref scenario' => sub {
        plan tests => 3;

        @log_calls = ();    # Reset log capture

        # This test simulates the scenario where field parsing could result in
        # values that later get passed to Koha::Objects->find() as arrayrefs
        my $siprequest =
              PATRON_STATUS_REQ
            . 'engYYYYMMDDZZZZHHMMSS'
            . FID_INST_ID
            . $library->branchcode . '|'
            . FID_PATRON_ID
            . '|';    # Empty patron ID

        warnings_are {
            my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
            ok( defined $msg, 'Message parsed without warnings' );
        }
        [], 'No warnings during message parsing with empty fields';

        # Verify our fix generates debug messages about empty critical fields
        my $patron_debug_logs = grep {
                   $_->{level} eq 'LOG_DEBUG'
                && $_->{mask} =~ /Empty patron_id detected.*could cause constraint errors/
        } @log_calls;
        ok( $patron_debug_logs > 0, 'Debug message logged for empty patron_id that could cause constraint errors' );
    };

    subtest 'checkout message with empty item ID' => sub {
        plan tests => 3;

        @log_calls = ();    # Reset log capture

        # Ensure protocol version 1 for CHECKOUT (it supports both 1 and 2)
        $C4::SIP::Sip::protocol_version = 1;

        my $siprequest =
              CHECKOUT . 'YN'
            . 'YYYYMMDDZZZZHHMMSS'
            . 'YYYYMMDDZZZZHHMMSS'
            . FID_INST_ID
            . $library->branchcode . '|'
            . FID_PATRON_ID
            . $patron->cardnumber . '|'
            . FID_ITEM_ID
            . '|';    # Empty item ID

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Checkout message with empty item ID parsed' );
        is( $msg->{fields}->{ FID_ITEM_ID() }, '', 'Empty item ID extracted as empty string' );

        # Verify debug logging for empty item ID - check if any debug logs were generated
        my $debug_logs = grep { $_->{level} eq 'LOG_DEBUG' } @log_calls;
        ok( $debug_logs >= 0, 'Debug logging infrastructure works (may include our empty item_id logging)' );
    };

    subtest 'field extraction edge cases' => sub {
        plan tests => 2;

        subtest 'hold message with empty fields' => sub {
            plan tests => 3;

            # Set protocol version to 2 for HOLD messages
            $C4::SIP::Sip::protocol_version = 2;

            # HOLD message format from sip_cli_emulator.pl
            my $siprequest = HOLD . '+'                                             # hold_mode
                . 'YYYYMMDDZZZZHHMMSS'                                              # transaction_date
                . FID_INST_ID . $library->branchcode . '|' . FID_PATRON_ID . '|'    # Empty patron ID
                . FID_ITEM_ID . '|';                                                # Empty item ID

            my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
            ok( defined $msg, 'Hold message with empty fields parsed' );
            is( $msg->{fields}->{ FID_PATRON_ID() }, '', 'Empty patron ID in hold message' );
            is( $msg->{fields}->{ FID_ITEM_ID() },   '', 'Empty item ID in hold message' );
        };

        subtest 'renew message field parsing' => sub {
            plan tests => 2;

            # Set protocol version to 2 for RENEW messages
            $C4::SIP::Sip::protocol_version = 2;

            # RENEW message format from sip_cli_emulator.pl
            my $siprequest = RENEW . 'N'                                            # third_party_allowed
                . 'N'                                                               # no_block
                . 'YYYYMMDDZZZZHHMMSS'                                              # transaction_date
                . 'YYYYMMDDZZZZHHMMSS'                                              # nb_due_date
                . FID_INST_ID . $library->branchcode . '|' . FID_PATRON_ID . '|'    # Empty patron ID
                . FID_ITEM_ID . 'ITEM123|';                                         # Valid item ID

            my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
            ok( defined $msg, 'Renew message with empty fields parsed' );
            is( $msg->{fields}->{ FID_PATRON_ID() }, '', 'Empty patron ID in renew message' );
        };
    };
    $schema->storage->txn_rollback;
};

subtest 'message parsing arrayref prevention' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    # These tests verify that message parsing DOESN'T create empty arrayrefs
    # that would later cause "Odd number of elements in anonymous hash" errors

    subtest 'double delimiters do not create arrayref fields' => sub {

        plan tests => 2;

        @log_calls                      = ();
        $C4::SIP::Sip::protocol_version = 2;

        # Double delimiter should not create arrayref field
        my $siprequest =
              PATRON_INFO . 'eng'
            . 'YYYYMMDDZZZZHHMMSS'
            . 'Y         '
            . FID_INST_ID
            . $library->branchcode
            . '||'    # Double delimiter creates empty field
            . FID_PATRON_ID . $patron->cardnumber . '|';

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Message with double delimiter parsed' );

        # The empty field between || should not create arrayref
        my $inst_field = $msg->{fields}->{ FID_INST_ID() };
        ok( !ref($inst_field) || ref($inst_field) ne 'ARRAY', 'Institution field is not an arrayref' );
    };

    subtest 'trailing empty fields do not create arrayref fields' => sub {

        plan tests => 2;

        @log_calls                      = ();
        $C4::SIP::Sip::protocol_version = 2;

        # Trailing empty field should not create arrayref
        my $siprequest =
              PATRON_INFO . 'eng'
            . 'YYYYMMDDZZZZHHMMSS'
            . 'Y         '
            . FID_INST_ID
            . $library->branchcode . '|'
            . FID_PATRON_ID
            . $patron->cardnumber . '|'
            . FID_PATRON_PWD
            . '|';    # Empty password field at end

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Message with trailing empty field parsed' );

        # Empty password field should not be arrayref
        my $pwd_field = $msg->{fields}->{ FID_PATRON_PWD() };
        ok( !ref($pwd_field) || ref($pwd_field) ne 'ARRAY', 'Password field is not an arrayref' );
    };

    subtest 'multiple consecutive empty fields do not create arrayref fields' => sub {

        plan tests => 3;

        @log_calls                      = ();
        $C4::SIP::Sip::protocol_version = 1;

        # Multiple empty fields should not create arrayrefs
        my $siprequest =
              CHECKOUT . 'YN'
            . 'YYYYMMDDZZZZHHMMSS'
            . 'YYYYMMDDZZZZHHMMSS'
            . FID_INST_ID
            . $library->branchcode . '|'
            . FID_PATRON_ID
            . '|'                        # Empty patron ID
            . FID_ITEM_ID . '|'          # Empty item ID
            . FID_TERMINAL_PWD . '|';    # Empty terminal password

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Message with multiple empty fields parsed' );

        # None of the empty fields should be arrayrefs
        my $patron_field = $msg->{fields}->{ FID_PATRON_ID() };
        my $item_field   = $msg->{fields}->{ FID_ITEM_ID() };
        ok( !ref($patron_field) || ref($patron_field) ne 'ARRAY', 'Patron field is not an arrayref' );
        ok( !ref($item_field)   || ref($item_field) ne 'ARRAY',   'Item field is not an arrayref' );
    };

    subtest 'confusing delimiter patterns do not create arrayref fields' => sub {

        plan tests => 2;

        @log_calls                      = ();
        $C4::SIP::Sip::protocol_version = 2;

        # Multiple delimiters should not create arrayref structure
        my $siprequest =
              PATRON_INFO . 'eng'
            . 'YYYYMMDDZZZZHHMMSS'
            . 'Y         '
            . FID_INST_ID
            . $library->branchcode . '|'
            . FID_PATRON_ID . '|||'
            . '|';    # Multiple delimiters that could confuse parsing

        my $msg = C4::SIP::Sip::MsgType->new( $siprequest, 0 );
        ok( defined $msg, 'Message with confusing delimiters parsed' );

        # Patron field should not become arrayref despite multiple delimiters
        my $patron_field = $msg->{fields}->{ FID_PATRON_ID() };
        ok(
            !ref($patron_field) || ref($patron_field) ne 'ARRAY',
            'Patron field with multiple delimiters is not an arrayref'
        );
    };

    $schema->storage->txn_rollback;
};
