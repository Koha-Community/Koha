#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2012-2013 ByWater Solutions
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

use Socket qw(:crlf);
use IO::Socket::INET;
use Getopt::Long;

use C4::SIP::Sip::Constants qw(:all);
use C4::SIP::Sip;

use constant { LANGUAGE => '001' };

my $help = 0;

my $host;
my $port = '6001';

my $login_user_id;
my $login_password;
my $location_code;

my $patron_identifier;
my $patron_password;

my $summary;

my $item_identifier;

my $fee_acknowledged;

my $fee_type;
my $payment_type;
my $currency_type;
my $fee_amount;
my $fee_identifier;
my $transaction_id;
my $pickup_location;
my $hold_mode;
my $no_block = 'N';

my $terminator = q{};

my @messages;

GetOptions(
    "a|address|host|hostaddress=s" => \$host,              # sip server ip
    "p|port=s"                     => \$port,              # sip server port
    "su|sip_user=s"                => \$login_user_id,     # sip user
    "sp|sip_pass=s"                => \$login_password,    # sip password
    "l|location|location_code=s"   => \$location_code,     # sip location code

    "patron=s"   => \$patron_identifier,                   # patron cardnumber or login
    "password=s" => \$patron_password,                     # patron's password

    "i|item=s" => \$item_identifier,

    "fa|fee-acknowledged=s" => \$fee_acknowledged,

    "s|summary=s" => \$summary,

    "fee-type=s"        => \$fee_type,
    "payment-type=s"    => \$payment_type,
    "currency-type=s"   => \$currency_type,
    "fee-amount=s"      => \$fee_amount,
    "fee-identifier=s"  => \$fee_identifier,
    "transaction-id=s"  => \$transaction_id,
    "pickup-location=s" => \$pickup_location,
    "hold-mode=s"       => \$hold_mode,
    "n|no-block=s"      => \$no_block,

    "t|terminator=s" => \$terminator,

    "m|message=s" => \@messages,

    'h|help|?' => \$help
);

if (   $help
    || !$host
    || !$login_user_id
    || !$login_password
    || !$location_code )
{
    say &help();
    exit();
}

$no_block   = $no_block eq 'Y'    ? 'Y' : 'N';
$terminator = $terminator eq 'CR' ? $CR : $CRLF;

# Set perl to expect the same record terminator it is sending
$/ = $terminator;

my $transaction_date = C4::SIP::Sip::timestamp();

my $terminal_password = $login_password;

$| = 1;
print "Attempting socket connection to $host:$port...";

my $socket = IO::Socket::INET->new("$host:$port")
  or die "failed! : $!\n";
say "connected!";

my $handlers = {
    login => {
        name       => 'Login',
        subroutine => \&build_login_command_message,
        parameters => {
            login_user_id  => $login_user_id,
            login_password => $login_password,
            location_code  => $location_code,
        },
    },
    sc_status_request => {
        name       => 'SC Status',
        subroutine => \&build_sc_status_command_message,
        parameters => {
        },
    },
    patron_status_request => {
        name       => 'Patron Status Request',
        subroutine => \&build_patron_status_request_command_message,
        parameters => {
            transaction_date  => $transaction_date,
            institution_id    => $location_code,
            patron_identifier => $patron_identifier,
            terminal_password => $terminal_password,
            patron_password   => $patron_password,
        },
        optional => [ 'patron_password', ],
    },
    patron_information => {
        name       => 'Patron Information',
        subroutine => \&build_patron_information_command_message,
        parameters => {
            transaction_date  => $transaction_date,
            institution_id    => $location_code,
            patron_identifier => $patron_identifier,
            terminal_password => $terminal_password,
            patron_password   => $patron_password,
            summary           => $summary,
        },
        optional => [ 'patron_password', 'summary' ],
    },
    item_information => {
        name       => 'Item Information',
        subroutine => \&build_item_information_command_message,
        parameters => {
            transaction_date  => $transaction_date,
            institution_id    => $location_code,
            item_identifier   => $item_identifier,
            terminal_password => $terminal_password,
        },
        optional => [],
    },
    checkout => {
        name       => 'Checkout',
        subroutine => \&build_checkout_command_message,
        parameters => {
            SC_renewal_policy => 'Y',
            no_block          => $no_block,
            transaction_date  => $transaction_date,
            nb_due_date       => undef,
            institution_id    => $location_code,
            patron_identifier => $patron_identifier,
            item_identifier   => $item_identifier,
            terminal_password => $terminal_password,
            item_properties   => undef,
            patron_password   => $patron_password,
            fee_acknowledged  => $fee_acknowledged,
            cancel            => undef,
        },
        optional => [
            'nb_due_date',    # defaults to transaction date
            'item_properties',
            'patron_password',
            'fee_acknowledged',
            'cancel',
        ],
    },
    checkin => {
        name       => 'Checkin',
        subroutine => \&build_checkin_command_message,
        parameters => {
            no_block          => $no_block,
            transaction_date  => $transaction_date,
            return_date       => $transaction_date,
            current_location  => $location_code,
            institution_id    => $location_code,
            item_identifier   => $item_identifier,
            terminal_password => $terminal_password,
            item_properties   => undef,
            cancel            => undef,
        },
        optional => [
            'return_date',    # defaults to transaction date
            'item_properties',
            'patron_password',
            'cancel',
        ],
    },
    renew => {
        name       => 'Renew',
        subroutine => \&build_renew_command_message,
        parameters => {
            third_party_allowed => 'N',
            no_block            => $no_block,
            transaction_date    => $transaction_date,
            nb_due_date         => undef,
            institution_id      => $location_code,
            patron_identifier   => $patron_identifier,
            patron_password     => $patron_password,
            item_identifier     => $item_identifier,
            title_identifier    => undef,
            terminal_password   => $terminal_password,
            item_properties     => undef,
            fee_acknowledged    => $fee_acknowledged,
        },
        optional => [
            'nb_due_date',    # defaults to transaction date
            'patron_password',
            'item_identifier',
            'title_identifier',
            'terminal_password',
            'item_properties',
            'fee_acknowledged',
        ],
    },
    fee_paid => {
        name       => 'Fee Paid',
        subroutine => \&build_fee_paid_command_message,
        parameters => {
            transaction_date  => $transaction_date,
            fee_type          => $fee_type,
            payment_type      => $payment_type,
            currency_type     => $currency_type,
            fee_amount        => $fee_amount,
            institution_id    => $location_code,
            patron_identifier => $patron_identifier,
            terminal_password => $terminal_password,
            patron_password   => $patron_password,
            fee_identifier    => $fee_identifier,
            transaction_id    => $transaction_id,
        },
        optional => [
            'fee_type', # has default
            'payment_type', # has default
            'currency_type', #has default
            'terminal_password',
            'patron_password',
            'fee_identifier',
            'transaction_id',
        ],
    },
    hold => {
        name       => 'Hold',
        subroutine => \&build_hold_command_message,
        parameters => {
            hold_mode           => $hold_mode eq '-' ? '-' : '+',
            transaction_date    => $transaction_date,
            expiration_date     => undef,
            pickup_location     => $pickup_location,
            hold_type           => undef,
            institution_id      => $location_code,
            patron_identifier   => $patron_identifier,
            patron_password     => $patron_password,
            item_identifier     => $item_identifier,
            title_identifier    => undef,
            terminal_password   => $terminal_password,
            fee_acknowledged    => $fee_acknowledged,
        },
        optional => [
            'expiration_date',
            'pickup_location',
            'hold_type',
            'patron_password',
            'item_identifier',
            'title_identifier',
            'terminal_password',
            'fee_acknowledged',
        ],
    },
};

my $data = run_command_message('login');

if ( $data =~ '^941' ) {    ## we are logged in
    foreach my $m (@messages) {
        say "Trying '$m'";

        my $data = run_command_message($m);

    }
}
else {
    say "Login Failed!";
}

sub build_command_message {
    my ($message) = @_;

    ##FIXME It would be much better to use exception handling so we aren't priting from subs
    unless ( $handlers->{$message} ) {
        say "$message is an unsupported command!";
        return;
    }

    my $subroutine = $handlers->{$message}->{subroutine};
    my $parameters = $handlers->{$message}->{parameters};
    my %optional   = map { $_ => 1 } @{ $handlers->{$message}->{optional} };

    foreach my $key ( keys %$parameters ) {
        unless ( $parameters->{$key} ) {
            unless ( $optional{$key} ) {
                say "$key is required for $message";
                return;
            }
        }
    }

    return &$subroutine($parameters);
}

sub run_command_message {
    my ($message) = @_;

    my $command_message = build_command_message($message);

    return unless $command_message;

    say "SEND: $command_message";
    print $socket $command_message . $terminator;

    my $data = <$socket>;

    say "READ: $data";

    return $data;
}

sub build_login_command_message {
    my ($params) = @_;

    my $login_user_id  = $params->{login_user_id};
    my $login_password = $params->{login_password};
    my $location_code  = $params->{location_code};

    return
        LOGIN . "00"
      . build_field( FID_LOGIN_UID,     $login_user_id )
      . build_field( FID_LOGIN_PWD,     $login_password )
      . build_field( FID_LOCATION_CODE, $location_code );
}

sub build_sc_status_command_message {
    my ($params) = @_;

    return SC_STATUS . "0" . "030" . "2.00";
}

sub build_patron_status_request_command_message {
    my ($params) = @_;

    my $transaction_date  = $params->{transaction_date};
    my $institution_id    = $params->{institution_id};
    my $patron_identifier = $params->{patron_identifier};
    my $terminal_password = $params->{terminal_password};
    my $patron_password   = $params->{patron_password};

    return
        PATRON_STATUS_REQ
      . LANGUAGE
      . $transaction_date
      . build_field( FID_INST_ID,      $institution_id )
      . build_field( FID_PATRON_ID,    $patron_identifier )
      . build_field( FID_TERMINAL_PWD, $terminal_password )
      . build_field( FID_PATRON_PWD,   $patron_password );
}

sub build_patron_information_command_message {
    my ($params) = @_;

    my $transaction_date  = $params->{transaction_date};
    my $institution_id    = $params->{institution_id};
    my $patron_identifier = $params->{patron_identifier};
    my $terminal_password = $params->{terminal_password};
    my $patron_password   = $params->{patron_password};
    my $summary           = $params->{summary};

    $summary //= "          ";

    return
        PATRON_INFO
      . LANGUAGE
      . $transaction_date
      . $summary
      . build_field( FID_INST_ID,      $institution_id )
      . build_field( FID_PATRON_ID,    $patron_identifier )
      . build_field( FID_TERMINAL_PWD, $terminal_password )
      . build_field( FID_PATRON_PWD,   $patron_password, { optional => 1 } );
}

sub build_item_information_command_message {
    my ($params) = @_;

    my $transaction_date  = $params->{transaction_date};
    my $institution_id    = $params->{institution_id};
    my $item_identifier   = $params->{item_identifier};
    my $terminal_password = $params->{terminal_password};

    return
        ITEM_INFORMATION
      . LANGUAGE
      . $transaction_date
      . build_field( FID_INST_ID,      $institution_id )
      . build_field( FID_ITEM_ID,      $item_identifier )
      . build_field( FID_TERMINAL_PWD, $terminal_password );
}

sub build_checkout_command_message {
    my ($params) = @_;

    my $SC_renewal_policy = $params->{SC_renewal_policy} || 'N';
    my $no_block          = $params->{no_block} || 'N';
    my $transaction_date  = $params->{transaction_date};
    my $nb_due_date       = $params->{nb_due_date};
    my $institution_id    = $params->{institution_id};
    my $patron_identifier = $params->{patron_identifier};
    my $item_identifier   = $params->{item_identifier};
    my $terminal_password = $params->{terminal_password};
    my $item_properties   = $params->{item_properties};
    my $patron_password   = $params->{patron_password};
    my $fee_acknowledged  = $params->{fee_acknowledged};
    my $cancel            = $params->{cancel} || 'N';

    $SC_renewal_policy = $SC_renewal_policy eq 'Y' ? 'Y' : 'N';
    $no_block          = $no_block          eq 'Y' ? 'Y' : 'N';
    $cancel            = $cancel            eq 'Y' ? 'Y' : 'N';

    $nb_due_date ||= $transaction_date;

    return
        CHECKOUT
      . $SC_renewal_policy
      . $no_block
      . $transaction_date
      . $nb_due_date
      . build_field( FID_INST_ID,      $institution_id )
      . build_field( FID_PATRON_ID,    $patron_identifier )
      . build_field( FID_ITEM_ID,      $item_identifier )
      . build_field( FID_TERMINAL_PWD, $terminal_password )
      . build_field( FID_ITEM_PROPS,   $item_properties, { optional => 1 } )
      . build_field( FID_PATRON_PWD,   $patron_password, { optional => 1 } )
      . build_field( FID_FEE_ACK,      $fee_acknowledged, { optional => 1 } )
      . build_field( FID_CANCEL,       $cancel, { optional => 1 } );
}

sub build_checkin_command_message {
    my ($params) = @_;

    my $no_block          = $params->{no_block} || 'N';
    my $transaction_date  = $params->{transaction_date};
    my $return_date       = $params->{return_date};
    my $current_location  = $params->{current_location};
    my $institution_id    = $params->{institution_id};
    my $item_identifier   = $params->{item_identifier};
    my $terminal_password = $params->{terminal_password};
    my $item_properties   = $params->{item_properties};
    my $cancel            = $params->{cancel} || 'N';

    $no_block = $no_block eq 'Y' ? 'Y' : 'N';
    $cancel   = $cancel   eq 'Y' ? 'Y' : 'N';

    $return_date ||= $transaction_date;

    return
        CHECKIN
      . $no_block
      . $transaction_date
      . $return_date
      . build_field( FID_CURRENT_LOCN, $current_location )
      . build_field( FID_INST_ID,      $institution_id )
      . build_field( FID_ITEM_ID,      $item_identifier )
      . build_field( FID_TERMINAL_PWD, $terminal_password )
      . build_field( FID_ITEM_PROPS,   $item_properties, { optional => 1 } )
      . build_field( FID_CANCEL,       $cancel, { optional => 1 } );
}

sub build_hold_command_message {
    my ($params) = @_;

    my $hold_mode         = $params->{hold_mode};
    my $transaction_date  = $params->{transaction_date};
    my $expiration_date   = $params->{expiration_date};
    my $pickup_location   = $params->{pickup_location};
    my $hold_type         = $params->{hold_type};
    my $institution_id    = $params->{institution_id};
    my $patron_identifier = $params->{patron_identifier};
    my $patron_password   = $params->{patron_password};
    my $item_identifier   = $params->{item_identifier};
    my $title_identifier  = $params->{title_identifier};
    my $terminal_password = $params->{terminal_password};
    my $fee_acknowledged  = $params->{fee_acknowledged};

    return
        HOLD
      . $hold_mode
      . $transaction_date
      . build_field( FID_EXPIRATION,   $expiration_date,   { optional => 1 } )
      . build_field( FID_PICKUP_LOCN,  $pickup_location,   { optional => 1 } )
      . build_field( FID_HOLD_TYPE,    $hold_type,         { optional => 1 } )
      . build_field( FID_INST_ID,      $institution_id                       )
      . build_field( FID_PATRON_ID,    $patron_identifier                    )
      . build_field( FID_PATRON_PWD,   $patron_password,   { optional => 1 } )
      . build_field( FID_ITEM_ID,      $item_identifier,   { optional => 1 } )
      . build_field( FID_TITLE_ID,     $title_identifier,  { optional => 1 } )
      . build_field( FID_TERMINAL_PWD, $terminal_password, { optional => 1 } )
      . build_field( FID_FEE_ACK,      $fee_acknowledged,  { optional => 1 } );
}

sub build_renew_command_message {
    my ($params) = @_;

    my $third_party_allowed = $params->{third_party_allowed} || 'N';
    my $no_block            = $params->{no_block}            || 'N';
    my $transaction_date    = $params->{transaction_date};
    my $nb_due_date         = $params->{nb_due_date};
    my $institution_id      = $params->{institution_id};
    my $patron_identifier   = $params->{patron_identifier};
    my $patron_password     = $params->{patron_password};
    my $item_identifier     = $params->{item_identifier};
    my $title_identifier    = $params->{title_identifier};
    my $terminal_password   = $params->{terminal_password};
    my $item_properties     = $params->{item_properties};
    my $fee_acknowledged    = $params->{fee_acknowledged};

    $third_party_allowed = $third_party_allowed eq 'Y' ? 'Y' : 'N';
    $no_block            = $no_block            eq 'Y' ? 'Y' : 'N';

    $nb_due_date ||= $transaction_date;

    return
        RENEW
      . $third_party_allowed
      . $no_block
      . $transaction_date
      . $nb_due_date
      . build_field( FID_INST_ID,      $institution_id )
      . build_field( FID_PATRON_ID,    $patron_identifier )
      . build_field( FID_PATRON_PWD,   $patron_password, { optional => 1 } )
      . build_field( FID_ITEM_ID,      $item_identifier )
      . build_field( FID_TITLE_ID,     $title_identifier )
      . build_field( FID_TERMINAL_PWD, $terminal_password )
      . build_field( FID_ITEM_PROPS,   $item_properties, { optional => 1 } )
      . build_field( FID_FEE_ACK,      $fee_acknowledged, { optional => 1 } );
}

sub build_fee_paid_command_message {
    my ($params) = @_;

    my $transaction_date  = $params->{transaction_date};
    my $fee_type          = $params->{fee_type} || '01';
    my $payment_type      = $params->{payment_type} || '00';
    my $currency_type     = $params->{currency_type} || 'USD';
    my $fee_amount        = $params->{fee_amount};
    my $institution_id    = $params->{location_code};
    my $patron_identifier = $params->{patron_identifier};
    my $terminal_password = $params->{terminal_password};
    my $patron_password   = $params->{patron_password};
    my $fee_identifier    = $params->{fee_identifier};
    my $transaction_id    = $params->{transaction_id};

    return
        FEE_PAID
      . $transaction_date
      . $fee_type
      . $payment_type
      . $currency_type
      . build_field( FID_FEE_AMT,        $fee_amount )
      . build_field( FID_INST_ID,        $institution_id )
      . build_field( FID_PATRON_ID,      $patron_identifier )
      . build_field( FID_TERMINAL_PWD,   $terminal_password, { optional => 1 } )
      . build_field( FID_PATRON_PWD,     $patron_password, { optional => 1 } )
      . build_field( FID_FEE_ID,         $fee_identifier, { optional => 1 } )
      . build_field( FID_TRANSACTION_ID, $transaction_id, { optional => 1 } );
}

sub build_field {
    my ( $field_identifier, $value, $params ) = @_;

    $params //= {};

    return q{} if ( $params->{optional} && !$value );

    return $field_identifier . (($value) ? $value : '') . '|';
}

sub help {
    say q/sip_cli_emulator.pl - SIP command line emulator

Test a SIP2 service by sending patron status and patron
information requests.

Usage:
  sip_cli_emulator.pl [OPTIONS]

Options:
  --help           display help message

  -a --address     SIP server ip address or host name
  -p --port        SIP server port

  -su --sip_user   SIP server login username
  -sp --sip_pass   SIP server login password

  -l --location    SIP location code

  --patron         ILS patron cardnumber or username
  --password       ILS patron password

  -s --summary     Optionally define the patron information request summary field.
                   Please refer to the SIP2 protocol specification for details

  --item           ILS item identifier ( item barcode )

  -t --terminator  SIP2 message terminator, either CR, or CRLF
                   (defaults to CRLF)

  -fa --fee-acknowledged Accepts "Y" to acknowledge a fee, "N" to not acknowledge it

  --fee-type        Fee type for Fee Paid message, defaults to '01'
  --payment-type    Payment type for Fee Paid message, default to '00'
  --currency-type   Currency type for Fee Paid message, defaults to 'USD'
  --fee-amount      Fee amount for Fee Paid message, required
  --fee-identifier  Fee identifier for Fee Paid message, optional
  --transaction-id  Transaction id for Fee Paid message, optional
  --pickup-location Pickup location (branchcode) for Hold message, optional
  --hold-mode       Accepts "+" to add hold or "-" to cancel hold, defaults to +
  -n --no-block     Accepts "N" for standard operatoin, "Y" for no-block, defaults to "N"

  -m --message     SIP2 message to execute

  Implemented Messages:
    checkin
    checkout
    fee_paid
    hold
    item_information
    patron_information
    patron_status_request
    sc_status_request
    renew
/
}
