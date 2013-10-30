#!/usr/bin/perl

use Modern::Perl;
use CGI;
use C4::Serials::Numberpattern;
use C4::Auth qw/check_cookie_auth/;
use URI::Escape;

my $input=new CGI;

my ($auth_status, $sessionID) = check_cookie_auth($input->cookie('CGISESSID'), { serials => '*' });
if ($auth_status ne "ok") {
    print $input->header(-type => 'text/plain', -status => '403 Forbidden');
    exit 0;
}

my $numpatternid=$input->param("numberpattern_id");

my $numberpatternrecord=GetSubscriptionNumberpattern($numpatternid);
binmode STDOUT, ":encoding(UTF-8)";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print "{",join (",",map {"\"$_\":\"".(uri_escape($numberpatternrecord->{$_}) // '')."\"" }sort keys %$numberpatternrecord),"}";
