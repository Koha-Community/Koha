#!/usr/bin/perl

use Modern::Perl;

use CGI qw ( -utf8 );
use CGI::Cookie; # need to check cookies before CGI parses the POST request
use JSON;

use C4::Context;
use C4::Biblio;
use C4::Auth qw/check_cookie_auth/;

my %cookies = CGI::Cookie->fetch;
my ( $auth_status, $sessionID ) = check_cookie_auth(
    $cookies{'CGISESSID'}->value, { editcatalogue => 'edit_catalogue' },
);
my $reply = CGI->new;
if ($auth_status ne "ok") {
    print $reply->header(-type => 'text/html');
    exit 0;
} 

my $framework = $reply->param('frameworkcode');
my $tagslib = GetMarcStructure(1, $framework);
print $reply->header(-type => 'text/html');
print encode_json $tagslib;
