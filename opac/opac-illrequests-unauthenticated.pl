#!/usr/bin/perl

use Modern::Perl;

use JSON qw( decode_json );

use CGI         qw ( -utf8 );
use C4::Auth    qw( get_template_and_user );
use C4::Output  qw( output_html_with_http_headers );
use URI::Escape qw( uri_unescape );

my $query = CGI->new;

my $sessionID = $query->cookie('CGISESSID');
my $session   = C4::Auth::get_session($sessionID);
my $request =
    eval { decode_json( uri_unescape( $session->param('ill_request_unauthenticated') ) ) };

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-illrequests_unauthenticated.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

$template->param( request => $request );

output_html_with_http_headers $query, $cookie, $template->output;
