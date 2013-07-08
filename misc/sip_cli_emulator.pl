#!/usr/bin/perl

use Modern::Perl;

use Socket qw(:crlf);
use IO::Socket::INET;
use Getopt::Long;

my $help = 0;

my $host;
my $port = '6001';

my $login_user_id;
my $login_password;
my $location_code;

my $patron_identifier;
my $patron_password;

my $terminator;

GetOptions(
    "a|address|host|hostaddress=s" => \$host,              # sip server ip
    "p|port=s"                     => \$port,              # sip server port
    "su|sip_user=s"                => \$login_user_id,     # sip user
    "sp|sip_pass=s"                => \$login_password,    # sip password
    "l|location|location_code=s"   => \$location_code,     # sip location code

    "patron=s"   => \$patron_identifier,    # patron cardnumber or login
    "password=s" => \$patron_password,      # patron's password

    "t|terminator=s" => \$terminator,

    'h|help|?' => \$help
);

if (   $help
    || !$host
    || !$login_user_id
    || !$login_password
    || !$location_code
    || !$patron_identifier
    || !$patron_password )
{
    print help();
    exit();
}

$terminator = ( $terminator eq 'CR' ) ? $CR : $CRLF;

my ( $sec, $min, $hour, $day, $month, $year ) = localtime(time);
$year += 1900;
my $transaction_date = "$year$month$day    $hour$min$sec";

my $institution_id    = $location_code;
my $terminal_password = $login_password;

my $socket = IO::Socket::INET->new("$host:$port")
  or die "ERROR in Socket Creation host=$host port=$port : $!\n";

my $login_command = "9300CN$login_user_id|CO$login_password|CP$location_code|";

print "\nOUTBOUND: $login_command\n";
print $socket $login_command . $terminator;

my $data = <$socket>;

print "\nINBOUND: $data\n";

if ( $data =~ '^941' ) { ## we are logged in

    ## Patron Status Request
    print "\nTrying 'Patron Status Request'\n";
    my $patron_status_request = "23001"
      . $transaction_date
      . "AO"  . $institution_id
      . "|AA" . $patron_identifier
      . "|AC" . $terminal_password
      . "|AD" . $patron_password;

    print "\nOUTBOUND: $patron_status_request\n";
    print $socket $patron_status_request . $terminator;

    $data = <$socket>;

    print "\nINBOUND: $data\n";

    ## Patron Information
    print "\nTrying 'Patron Information'\n";
    my $summary = "          ";
    $patron_status_request = "63001"
      . $transaction_date
      . $summary
      . "AO"  . $institution_id
      . "|AA" . $patron_identifier
      . "|AC" . $terminal_password
      . "|AD" . $patron_password;

    print "\nOUTBOUND: $patron_status_request\n";
    print $socket $patron_status_request . $terminator;

    $data = <$socket>;

    print "\nINBOUND: $data\n";

}
else {
    print "\nLogin Failed!\n";
}

sub help() {
    print
q/
sip_cli_emulator.pl - SIP command line emulator

  Usage:
    sip_cli_emulator.pl --address localhost -port 6001 --sip_user myuser --sip_pass mypass --location MYLOCATION --patron 70000003 --password Patr0nP@ssword

  Options:
    --help          brief help message

    -a --address    SIP server ip address or host name
    -p --port       SIP server port

    -su --sip_user  SIP server login username
    -sp --sip_pass  SIP server login password

    -l --location   SIP location code

    --patron        ILS patron cardnumber or username
    --password      ILS patron password

    -t --terminator    Specifies the SIP2 message terminator, either CR, or CRLF ( defaults to CRLF )

sip_cli_emulator.pl will make requests for information about the given user from the given server via SIP2.

/

}
