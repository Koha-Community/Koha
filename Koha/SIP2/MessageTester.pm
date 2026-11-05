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

use Encode                    qw( decode );
use Module::Load::Conditional qw( can_load );
use Try::Tiny                 qw( catch try );

use C4::Circulation qw( barcodedecode );
use C4::Context;
use C4::SIP::Sip            qw( timestamp );
use C4::SIP::Sip::Constants qw( :all );
use C4::SIP::ILS::Patron;
use C4::SIP::Sip::Configuration;
use C4::SIP::Sip::MsgType;

use Koha::BackgroundJob;
use Koha::Database;
use Koha::Exception;
use Koha::Exceptions;
use Koha::Exceptions::Patron;
use Koha::Items;
use Koha::Libraries;
use Koha::Logger;
use Koha::Patron;
use Koha::Patrons;

# The language field sent in every request. '001' is English.
use constant LANGUAGE => '001';

# The request messages the tester will run, the same ones the staff interface
# can build. Anything else ( a login, a hold, a fee paid, ... ) is refused.
my %SUPPORTED_REQUESTS = map { $_ => 1 } ( PATRON_STATUS_REQ, PATRON_INFO, ITEM_INFORMATION, CHECKOUT, CHECKIN );

# The detail a patron information request can ask for, in the order of the
# positions of the ten character summary field of the request. The server reads
# the first Y only, so there is one choice.
my @SUMMARY_DETAILS = qw( hold_items overdue_items charged_items fine_items recall_items unavailable_holds );

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

The handlers run inside a transaction that is always rolled back, so database
changes made by even checkout and checkin messages are undone. That is the only
thing that is undone: plugin hooks ( for instance after_circ_action ) still run,
and anything a plugin sends elsewhere is not recalled. Publishing of background
job messages is suppressed while the handler runs and the "last seen" activity
is not recorded. Every test is logged ( who, which account, which message ) so it
can be audited.

A patron password is never checked. A request that carries one says what the
outcome should be instead: GOOD makes the password count as the patron's, BAD
makes it count as wrong. A real password is refused. If it were not, the tester
would let anyone who can use it try passwords for the patrons they can see,
without the lockout of the real SIP server, as the failed attempts are rolled
back with everything else.

The handlers run with the session of the SIP account's own user and institution,
as they do after a real SIP login, not the session of the staff member running
the test.

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
            patron_password => 'GOOD',
            summary         => 'fine_items',
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

A patron information request can ask for one list of items in the response, with
the 'summary' parameter: 'hold_items', 'overdue_items', 'charged_items',
'fine_items', 'recall_items' or 'unavailable_holds'. Without it the lists are
left out, and so are the templates that format them ( the fines, for one ).

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

    # The session a real SIP login has. Found before anything is run so the test
    # fails early if the account has no patron to log in as.
    my $sip_userenv = $self->_sip_userenv($server);

    $self->_log_test($request);

    my $schema   = Koha::Database->new->schema;
    my $response = q{};
    my $error;

    # Where we got to when something failed: refusing the request is not the
    # same as the handler failing.
    my $stage = 'check';

    # These C4::SIP::Sip globals are imported into MsgType, so localizing them
    # would not be seen by the handler ( the import aliases the original
    # scalar ). Set them in place and restore the previous values afterwards.
    # Protocol version 2 is required for the patron and item information
    # messages, error detection off keeps the response free of a checksum.
    my @saved_globals = (
        $C4::SIP::Sip::protocol_version, $C4::SIP::Sip::error_detection,
        $C4::SIP::Sip::last_response,    $C4::SIP::Sip::field_delimiter
    );
    my $saved_userenv = C4::Context->userenv;

    # Run the handler in a transaction we always roll back so nothing is
    # actually changed, even for checkout and checkin. Begin it before any
    # global is touched, so a failure to begin leaves nothing to undo.
    $schema->txn_begin;

    try {
        $C4::SIP::Sip::protocol_version = 2;
        $C4::SIP::Sip::error_detection  = 0;
        $C4::SIP::Sip::last_response    = q{};

        # Checked here rather than up front because parsing the patron and item
        # information requests needs the protocol version set above. It must
        # run before the session below, it depends on who is logged in.
        $self->_check_request($request);
        $stage = 'handler';

        C4::Context->set_userenv( @{$sip_userenv} );

        # The handler prints the response to STDOUT and stashes it in
        # $last_response. Capture STDOUT so it doesn't leak into the worker's
        # output, and localize %ENV so the system preference overrides the
        # handler sets don't outlive this call.
        my $captured = q{};
        local *STDOUT;
        open STDOUT, '>', \$captured or die "Can't capture STDOUT: $!";

        local %ENV = %ENV;

        # Things that reach outside the transaction, which rolling it back
        # would not undo.
        no warnings 'redefine';

        # Background jobs are published to the message broker as soon as they
        # are enqueued, the workers would be told about jobs that never
        # existed. Without a connection enqueue only stores the job row, which
        # we roll back.
        local *Koha::BackgroundJob::connect = sub { return };

        # update_lastseen stores the date, which is rolled back, and remembers
        # in the cache that it did so for the day, which is not. A real
        # connection afterwards would then skip the update.
        local *Koha::Patron::update_lastseen = sub { return $_[0] };

        # The password of the patron is not checked, GOOD is a password that
        # matches and anything else is one that does not. Checking a real one
        # would make this a way to guess the password of any patron.
        local *C4::SIP::ILS::Patron::check_password = sub {
            my ( $patron, $password ) = @_;
            return ( defined $password && $password eq 'GOOD' ) ? 1 : 0;
        };

        C4::SIP::Sip::MsgType::handle( $request, $server, q{} );

        $response = $C4::SIP::Sip::last_response;
    } catch {
        $error = $_;
    };

    # Put everything back with plain statements, not a finally block: an error
    # thrown from a finally block is swallowed by Try::Tiny, and a rollback that
    # silently failed would leave the changes in place.
    (
        $C4::SIP::Sip::protocol_version, $C4::SIP::Sip::error_detection,
        $C4::SIP::Sip::last_response,    $C4::SIP::Sip::field_delimiter
    ) = @saved_globals;
    $self->_restore_userenv($saved_userenv);

    my $rollback_error;
    try { $schema->txn_rollback } catch { $rollback_error = $_ };

    Koha::Exception->throw( error => "Could not roll back the test transaction: $rollback_error" )
        if $rollback_error;

    if ($error) {

        # A refusal of the request is thrown as it is. Anything thrown by a
        # handler is a server side problem, not something wrong with the request,
        # so don't hand it back as an exception that a caller might read as bad
        # input, a missing patron or a refusal.
        die $error if $stage eq 'check';
        Koha::Exception->throw( error => 'The SIP message handler failed: ' . $error );
    }

    # The server writes the response in the encoding of the account, show it as
    # the characters a terminal reads from it.
    my $encoding = $server->{account}->{encoding};
    $response = decode( $encoding, $response ) if $encoding && length $response;

    my ( $fixed, $fields ) = $self->_parse_response($response);

    return {
        request  => $request,
        response => $response,
        fixed    => $fixed,
        fields   => $fields,
    };
}

=head2 Internal methods

=head3 _sip_userenv

Returns the arguments for C4::Context->set_userenv that describe the session a
real SIP login would have had: the patron the account logs in as, at the
institution's library.

=cut

sub _sip_userenv {
    my ( $self, $server ) = @_;

    my $login_id = $self->{account}->login_id;
    my $patron   = Koha::Patrons->find( { userid => $login_id } )
        or Koha::Exceptions::ObjectNotFound->throw(
        "No patron with the userid '$login_id' that the SIP account logs in as");

    my $institution_id = $server->{account}->{institution};
    my $library        = Koha::Libraries->find($institution_id);

    return [
        $patron->borrowernumber, $patron->userid, $patron->cardnumber,                   $patron->firstname,
        $patron->surname,        $institution_id, $library ? $library->branchname : q{}, $patron->flags,
        $patron->email,
    ];
}

=head3 _restore_userenv

Puts back the session that was in place before the test.

=cut

sub _restore_userenv {
    my ( $self, $saved ) = @_;

    if ($saved) {
        C4::Context->set_userenv(
            @{$saved}{
                qw( number id cardnumber firstname surname branch branchname flags emailaddress
                    shibboleth desk_id desk_name register_id register_name session_id )
            }
        );
    } else {
        C4::Context->unset_userenv;
    }

    return;
}

=head3 _log_test

Logs who ran which message against which account. This is done outside the
transaction that is rolled back, so the record of a test always survives. The
patron and item identifiers are left out on purpose.

The prefix that Koha::Logger adds under Plack is turned off: the default
configuration only logs plack-api from WARN, so an INFO line would be dropped
for every request the web server handles.

=cut

sub _log_test {
    my ( $self, $request ) = @_;

    my $userenv = C4::Context->userenv;
    Koha::Logger->get( { interface => 'api', category => 'sip2.message_tester', prefix => 0 } )->info(
        sprintf(
            'SIP2 message tester: user %s ran message %s against account %s',
            $userenv ? $userenv->{number} : 'unknown',
            substr( $request, 0, 2 ),
            $self->{account}->sip_account_id,
        )
    );

    return;
}

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
    Koha::Exceptions::ObjectNotFound->throw("SIP institution '$institution_id' not found in configuration")
        unless $config->{institutions}->{$institution_id};

    $server->{institution} = $config->{institutions}->{$institution_id};
    $server->{policy}      = $server->{institution}->{policy};

    my $module = $server->{institution}->{implementation};
    $module = 'C4::SIP::ILS' if $module eq 'ILS';
    can_load( modules => { $module => undef } )
        or Koha::Exception->throw(
        error => "Cannot load the SIP implementation '$module': $Module::Load::Conditional::ERROR" );
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
        return
              PATRON_INFO
            . LANGUAGE
            . $date
            . _summary( $params->{summary} )
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

    # Whatever the request holds as the patron password is not checked, but a
    # real one in a request would still be a password somebody typed in, so say
    # that GOOD and BAD are what to use instead of ignoring it.
    my $patron_password = $fields->{ (FID_PATRON_PWD) };
    Koha::Exceptions::BadParameter->throw("A patron password cannot be tested, use GOOD or BAD")
        if defined $patron_password && length $patron_password && $patron_password !~ /\A(?:GOOD|BAD)\z/;

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
            value => length $chunk > 2 ? substr( $chunk, 2 ) : q{},
            };
    }

    return ( $fixed, \@fields );
}

=head3 _summary

    my $summary = _summary('fine_items');

Builds the ten character summary field of a patron information request: spaces,
or a Y at the position of the detail that is asked for. Without a detail, the
server leaves out the lists of items.

=cut

sub _summary {
    my ($detail) = @_;

    return ( q{ } x 10 ) unless defined $detail && length $detail;

    my ($position) = grep { $SUMMARY_DETAILS[$_] eq $detail } 0 .. $#SUMMARY_DETAILS;
    Koha::Exceptions::BadParameter->throw(
        parameter => 'summary',
        error     => "Unsupported summary '$detail'",
    ) unless defined $position;

    my @summary = (q{ }) x 10;
    $summary[$position] = 'Y';

    return join q{}, @summary;
}

=head3 _field

Builds a single variable length field. An optional field with no value is
omitted entirely. A value containing the field delimiter is refused, it would
add fields to the request that the form didn't ask for.

=cut

sub _field {
    my ( $field_id, $value, $params ) = @_;
    $params //= {};

    return q{} if $params->{optional} && !( defined $value && length $value );

    Koha::Exceptions::BadParameter->throw(
        parameter => $field_id,
        error     => "The field delimiter cannot be used in the value for '$field_id'",
    ) if defined $value && index( $value, q{|} ) != -1;

    return $field_id . ( defined $value ? $value : q{} ) . '|';
}

1;
