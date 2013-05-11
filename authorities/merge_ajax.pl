#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Session;
use C4::Context;
use C4::Auth qw/check_cookie_auth/;
use C4::AuthoritiesMarc;
use JSON;
use CGI::Cookie; # need to check cookies before
                 # having CGI parse the POST request

my %cookies = fetch CGI::Cookie;
my ($auth_status, $sessionID) = check_cookie_auth($cookies{'CGISESSID'}->value, { editcatalogue => 'edit_catalogue' });
if ($auth_status ne "ok") {
    my $reply = CGI->new("");
    print $reply->header(-type => 'text/html');
    exit 0;
}

my $reply = new CGI;
my $framework = $reply->param('frameworkcode');
my $tagslib = GetTagsLabels(1, $framework);
print $reply->header(-type => 'text/html');
print encode_json $tagslib;
