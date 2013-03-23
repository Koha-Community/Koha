#!/usr/bin/perl

use CGI;
use C4::Context;
use C4::Serials::Frequency;
use C4::Auth qw/check_cookie_auth/;
use URI::Escape;
use strict;

my $input=new CGI;
my $frqid=$input->param("frequency_id");
my ($auth_status, $sessionID) = check_cookie_auth($input->cookie('CGISESSID'), { serials => '*' });
if ($auth_status ne "ok") {
    exit 0;
}
my $frequencyrecord=GetSubscriptionFrequency($frqid);
binmode STDOUT, ":encoding(UTF-8)";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print "{".join (",",map { "\"$_\":\"".uri_escape($frequencyrecord->{$_})."\"" }sort keys %$frequencyrecord)."}";
