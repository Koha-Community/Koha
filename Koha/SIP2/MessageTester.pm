package Koha::SIP2::MessageTester;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Try::Tiny qw( catch finally try );
use UNIVERSAL::require;

use C4::Circulation qw( barcodedecode );
use C4::Context;
use C4::SIP::Sip            qw( timestamp );
use C4::SIP::Sip::Constants qw( :all );
use C4::SIP::Sip::Configuration;
use C4::SIP::Sip::MsgType;

use Koha::Database;
use Koha::Exceptions;
use Koha::Exceptions::Patron;
use Koha::Items;
use Koha::Patrons;

# The language field sent in every request. '001' is English.
use constant LANGUAGE => '001';

# The request messages the tester will run, the same ones the staff interface
# can build. Anything else ( a login, a hold, a fee paid, ... ) is refused.
my %SUPPORTED_REQUESTS = map { $_ => 1 } ( PATRON_STATUS_REQ, PATRON_INFO, ITEM_INFORMATION, CHECKOUT, CHECKIN );

# Number of characters at the start of each response that make up the
# message code plus the fixed length fields, keyed by response code. The
# variable length fields that hold the interesting template values follow.
my %FIXED_LENGTH = (
    PATRON_STATUS_RESP() => 37,    # 2 code + 14 status + 3 language + 18 date
    PATRON_INFO_RESP()   => 61,    # adds the six 4 char summary counts
    ITEM_INFO_RESP()     => 26,    # 2 code + 6 status chars + 18 date
    CHECKOUT_RESP()      => 24,    # 2 code + 4 flag chars + 18 date
    CHECKIN_RESP()       => 24,    # 2 code + 4 flag chars + 18 date
);

=head1 NAME

Koha::SIP2::MessageTester - Generate a SIP2 response for a saved account without a socket

=head1 SYNOPSIS

    my $tester = Koha::SIP2::MessageTester->new( { account => $sip_account } );
    my $result = $tester->run( { message => 'patron_information', patron_id => '23529000000001' } );

=head1 DESCRIPTION

Builds the same server context the SIP server builds at login time ( minus the
authentication ) from a saved Koha::SIP2::Account, hands a constructed request
to the real message handlers, and returns the generated response. This lets a
librarian check the value of the custom template fields configured on an account
without knowing the SIP account password.

The whole thing runs inside a transaction that is always rolled back, so even
checkout and checkin messages don't actually do anything.

=head1 API

=head2 Class methods

=head3 new

    my $tester = Koha::SIP2::MessageTester->new( { account => $sip_account } );

=cut

sub new {
    my ( $class, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing 'account' parameter")
        unless $params->{account};

    my $self = { account => $params->{account} };
    return bless $self, $class;
}

=head3 run

    my $result = $tester->run(
        {
            message         => 'patron_information',
            patron_id       => $patron_barcode,
            item_id         => $item_barcode,
            patron_password => $patron_password,
        }
    );

    # or run a raw request string built elsewhere ( the staff interface )
    my $result = $tester->run( { request => '6300120240101    100000          AOMPL|AA23529000000001|' } );

Generates the response for the requested message and returns a hashref:

    {
        request  => $raw_request_string,
        response => $raw_response_string,
        fixed    => $fixed_length_portion,
        fields   => [ { field => 'AO', value => 'MPL' }, ... ],
    }

A raw 'request' string is used as-is if given, otherwise the request is built
from 'message' and the patron/item parameters. Valid messages are
'patron_status', 'patron_information', 'item_information', 'checkout' and
'checkin'.

The logged in user's restrictions apply: a patron the user cannot see throws
Koha::Exceptions::Patron::NotFound, and when IndependentBranches is enabled an
item from another library throws Koha::Exceptions::NoPermission.

=cut

sub run {
    my ( $self, $params ) = @_;

    my $server = $self->_build_server;

    my $request = $params->{request};
    unless ( defined $request && length $request ) {
        my $message = $params->{message}
            or Koha::Exceptions::MissingParameter->throw("Missing 'message' or 'request' parameter");
        $request = $self->_build_request( $server, $message, $params );
    }

    # Run the handler in a transaction we always roll back so nothing is
    # actually changed, even for checkout and checkin.
    my $schema   = Koha::Database->new->schema;
    my $response = q{};
    my $error;

    # These C4::SIP::Sip globals are imported into MsgType, so localizing them
    # would not be seen by the handler ( the import aliases the original
    # scalar ). Set them in place and restore the previous values afterwards.
    # Protocol version 2 is required for the patron and item information
    # messages, error detection off keeps the response free of a checksum.
    my $saved_protocol_version = $C4::SIP::Sip::protocol_version;
    my $saved_error_detection  = $C4::SIP::Sip::error_detection;
    my $saved_last_response    = $C4::SIP::Sip::last_response;
    $C4::SIP::Sip::protocol_version = 2;
    $C4::SIP::Sip::error_detection  = 0;
    $C4::SIP::Sip::last_response    = q{};

    $schema->txn_begin;
    try {
        # Checked here rather than up front because parsing the patron and item
        # information requests needs the protocol version set above.
        $self->_check_request($request);

        # The handler prints the response to STDOUT and stashes it in
        # $last_response. Capture STDOUT so it doesn't leak into the worker's
        # output, and localize %ENV so the system preference overrides the
        # handler sets don't outlive this call.
        my $captured = q{};
        local *STDOUT;
        open STDOUT, '>', \$captured or die "Can't capture STDOUT: $!";

        local %ENV = %ENV;

        C4::SIP::Sip::MsgType::handle( $request, $server, q{} );

        $response = $C4::SIP::Sip::last_response;
    } catch {
        $error = $_;
    } finally {
        $C4::SIP::Sip::protocol_version = $saved_protocol_version;
        $C4::SIP::Sip::error_detection  = $saved_error_detection;
        $C4::SIP::Sip::last_response    = $saved_last_response;
        $schema->txn_rollback;
    };

    die $error if $error;

    my ( $fixed, $fields ) = $self->_parse_response($response);

    return {
        request  => $request,
        response => $response,
        fixed    => $fixed,
        fields   => $fields,
    };
}

=head2 Internal methods

=head3 _build_server

Builds the server context ( config, account, institution, policy and ils ) for
the saved account, the same way C4::SIP::Sip::MsgType::login_core does but
without authenticating.

=cut

sub _build_server {
    my ($self) = @_;

    my $login_id = $self->{account}->login_id;

    # Configuration->new with no file reads the accounts, institutions and
    # global system preference overrides straight from the database.
    my $config = C4::SIP::Sip::Configuration->new();

    Koha::Exceptions::ObjectNotFound->throw("SIP account '$login_id' not found in configuration")
        unless $config->{accounts}->{$login_id};

    my $server = { config => $config };
    $server->{account} = $config->{accounts}->{$login_id};

    my $institution_id = $server->{account}->{institution};
    $server->{institution} = $config->{institutions}->{$institution_id};
    $server->{policy}      = $server->{institution}->{policy};

    my $module = $server->{institution}->{implementation};
    $module = 'C4::SIP::ILS' if $module eq 'ILS';
    $module->use;
    $server->{ils} = $module->new( $server->{institution}, $server->{account} );

    return $server;
}

=head3 _build_request

Builds the raw SIP request string for the given message type.

=cut

sub _build_request {
    my ( $self, $server, $message, $params ) = @_;

    my $institution_id = $server->{account}->{institution};
    my $date           = timestamp();

    my $patron_id       = $params->{patron_id}       // q{};
    my $item_id         = $params->{item_id}         // q{};
    my $patron_password = $params->{patron_password} // q{};

    if ( $message eq 'patron_status' ) {
        return
              PATRON_STATUS_REQ
            . LANGUAGE
            . $date
            . _field( FID_INST_ID,      $institution_id )
            . _field( FID_PATRON_ID,    $patron_id )
            . _field( FID_TERMINAL_PWD, q{} )
            . _field( FID_PATRON_PWD,   $patron_password, { optional => 1 } );
    } elsif ( $message eq 'patron_information' ) {
        return PATRON_INFO . LANGUAGE . $date . '          '    # summary, ten spaces, no detail requested
            . _field( FID_INST_ID,      $institution_id )
            . _field( FID_PATRON_ID,    $patron_id )
            . _field( FID_TERMINAL_PWD, q{} )
            . _field( FID_PATRON_PWD,   $patron_password, { optional => 1 } );
    } elsif ( $message eq 'item_information' ) {

        # The item information request has no language field, unlike the patron
        # messages.
        return
              ITEM_INFORMATION
            . $date
            . _field( FID_INST_ID,      $institution_id )
            . _field( FID_ITEM_ID,      $item_id )
            . _field( FID_TERMINAL_PWD, q{} );
    } elsif ( $message eq 'checkout' ) {
        return CHECKOUT . 'N'    # SC renewal policy
            . 'N'                # no block
            . $date              # transaction date
            . $date              # nb due date
            . _field( FID_INST_ID,      $institution_id )
            . _field( FID_PATRON_ID,    $patron_id )
            . _field( FID_ITEM_ID,      $item_id )
            . _field( FID_TERMINAL_PWD, q{} )
            . _field( FID_PATRON_PWD,   $patron_password, { optional => 1 } );
    } elsif ( $message eq 'checkin' ) {
        return CHECKIN . 'N'     # no block
            . $date              # transaction date
            . $date              # return date
            . _field( FID_CURRENT_LOCN, $institution_id )
            . _field( FID_INST_ID,      $institution_id )
            . _field( FID_ITEM_ID,      $item_id )
            . _field( FID_TERMINAL_PWD, q{} );
    }

    Koha::Exceptions::BadParameter->throw("Unsupported message '$message'");
}

=head3 _check_request

Refuses a request the logged in user should not be able to run: a message the
tester does not support, a patron the user cannot see, or when
IndependentBranches is enabled, an item from another library.

=cut

sub _check_request {
    my ( $self, $request ) = @_;

    my $code = substr( $request, 0, 2 );
    Koha::Exceptions::BadParameter->throw("Unsupported message '$code'")
        unless $SUPPORTED_REQUESTS{$code};

    # Parse the request the same way the handler does, so we check the same
    # patron and item the handler will look up, even for a hand edited request.
    my $fields = C4::SIP::Sip::MsgType->new( $request, 0 )->{fields};

    my $patron_id = $fields->{ (FID_PATRON_ID) };
    if ( defined $patron_id && length $patron_id ) {
        my $patron = Koha::Patrons->find_by_identifier($patron_id);
        Koha::Exceptions::Patron::NotFound->throw("Patron not found")
            unless $patron && Koha::Patrons->search_limited->find( $patron->borrowernumber );
    }

    my $item_id = $fields->{ (FID_ITEM_ID) };
    if (   defined $item_id
        && length $item_id
        && C4::Context->preference('IndependentBranches')
        && !C4::Context->IsSuperLibrarian )
    {
        my $item = Koha::Items->find( { barcode => barcodedecode($item_id) } );
        Koha::Exceptions::NoPermission->throw("Item belongs to another library")
            if $item && $item->homebranch ne C4::Context->userenv->{branch};
    }
}

=head3 _parse_response

Splits a raw response into its fixed length portion and the list of variable
length fields, so the variable fields ( where the custom template values live )
can be displayed one per row.

=cut

sub _parse_response {
    my ( $self, $response ) = @_;

    return ( q{}, [] ) unless length $response;

    my $code   = substr( $response, 0, 2 );
    my $length = $FIXED_LENGTH{$code} // 2;
    $length = length $response if $length > length $response;

    my $fixed     = substr( $response, 0, $length );
    my $remainder = substr( $response, $length );

    my @fields;
    foreach my $chunk ( split /\|/, $remainder, -1 ) {
        next unless length $chunk;
        push @fields,
            {
            field => substr( $chunk, 0, 2 ),
            value => substr( $chunk, 2 ),
            };
    }

    return ( $fixed, \@fields );
}

=head3 _field

Builds a single variable length field. An optional field with no value is
omitted entirely.

=cut

sub _field {
    my ( $field_id, $value, $params ) = @_;
    $params //= {};

    return q{} if $params->{optional} && !$value;

    return $field_id . ( defined $value ? $value : q{} ) . '|';
}

1;
