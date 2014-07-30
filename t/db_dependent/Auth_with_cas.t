#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 2;
use CGI;

use C4::Context;

BEGIN {
        use_ok('C4::Auth_with_cas');
}

my $opac_base_url = C4::Context->preference('OpacBaseURL');
my $query_string = 'ticket=foo&bar=baz';

$ENV{QUERY_STRING} = $query_string;
$ENV{SCRIPT_NAME} = '/cgi-bin/koha/opac-user.pl';

my $cgi = new CGI($query_string);
$cgi->delete('ticket');

# _url_with_get_params should return the URL without 'ticket' parameter since it
# has been deleted.
is(C4::Auth_with_cas::_url_with_get_params($cgi),
    "$opac_base_url/cgi-bin/koha/opac-user.pl?bar=baz");
