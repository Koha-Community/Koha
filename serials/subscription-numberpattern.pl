#!/usr/bin/perl

use CGI;
use C4::Serials::Numberpattern;
use URI::Escape;
use strict;
use warnings;

my $input=new CGI;
my $numpatternid=$input->param("numberpattern_id");

my $numberpatternrecord=GetSubscriptionNumberpattern($numpatternid);
binmode STDOUT, ":utf8";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print "{",join (",",map {"\"$_\":\"".(uri_escape($numberpatternrecord->{$_}) // '')."\"" }sort keys %$numberpatternrecord),"}";
