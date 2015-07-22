#!/usr/bin/perl

use strict;
use warnings;

use CGI qw ( -utf8 );
use CGI::Cookie; # need to check cookies before CGI parses the POST request
use JSON;

use C4::Context;
use C4::Auth qw/check_cookie_auth/;
use C4::AuthoritiesMarc;

my %cookies = CGI::Cookie->fetch;
my ($auth_status, $sessionID) = check_cookie_auth($cookies{'CGISESSID'}->value, { editcatalogue => 'edit_catalogue' });
my $reply = CGI->new;
if ($auth_status ne "ok") {
    print $reply->header(-type => 'text/html');
    exit 0;
}

my $framework = $reply->param('frameworkcode');
my $tagslib = GetTagsLabels(1, $framework);
print $reply->header(-type => 'text/html');
print encode_json $tagslib;
