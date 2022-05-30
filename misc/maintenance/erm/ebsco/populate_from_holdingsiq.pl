use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use JSON qw( from_json to_json );
use HTTP::Request;
use LWP::UserAgent;

our ( $custid, $api_key );
my( $help, $verbose );
GetOptions(
    'help|h' => \$help,
    'verbose|v' => \$verbose,
    'custid:s' => \$custid,
    'api-key:s' => \$api_key,
) || podusage(1);

pod2usage(1) if $help;
pod2usage("Parameters 'custid' and 'api-key' are mandatory") unless $custid && $api_key;

my $status = get_status();
say "Status of the snapshot: $status";
if ( $status ne 'Completed' && $status ne 'In Progress' ) {
    say "Populate holdings...";
    populate_holdings();
}

while ($status ne 'Completed') {
    sleep(60);
    $status = get_status();
    say "Status: " . $status;
}

sub get_status {
    my $response= request(GET => '/holdings/status');
    my $result = from_json( $response->decoded_content );
    return $result->{status};
}

sub populate_holdings {
    my $response = request( POST => '/holdings' );
    if ( $response->code != 202 && $response->code != 409 ) {
        my $result = from_json( $response->decoded_content );
        die sprintf "ERROR - code %s: %s\n", $response->code,
          $result->{message};
    }
}

sub request {
    my ( $method, $url ) = @_;

    my $base_url = 'https://api.ebsco.io/rm/rmaccounts/' . $custid;
    my $request = HTTP::Request->new( $method => $base_url . $url);
    $request->header( 'x-api-key' => $api_key );
    my $ua = LWP::UserAgent->new;
    return $ua->simple_request($request);
}
