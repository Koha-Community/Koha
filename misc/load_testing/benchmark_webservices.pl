#!/usr/bin/perl
use strict;
use warnings;
#Usage:
# perl testKohaWS.pl http://eowyn.metavore.com:8001/cgi-bin/koha/svc cfc cfc 0.5 5 records/xml/xml-recs.xml
#
# POSTs to baseurl x number of times with y secs of delay between POSTs
#
# args:
# http://eowyn.metavore.com:8001/cgi-bin/koha/svc = baseurl
# 1st cfc = userid
# 2nd cfc = pw
# 0.5 = sleep(0.5) between POSTs
# 5 = number of times to poast
# records/xml/xml-recs.xml = file of 1 marcxml record to post
#
# Requires LWP::UserAgent, File::Slurp.
use LWP::UserAgent;
use File::Slurp qw(slurp);
use Carp;
my $ua = LWP::UserAgent->new();
$ua->cookie_jar({ file =>"cookies.txt" });
my $baseurl = shift;
my $userid = shift;
my $password = shift;
my $timeout = shift;
my $timestopost = shift;
my $xmlfile = shift;

my $xmldoc = slurp($xmlfile) or die $!;
# auth
my $resp = $ua->post( $baseurl . '/authentication' , {userid =>$userid, password => $password} );
if( $resp->is_success ) {
	print "Auth:\n";
	print $resp->content;
}
else {
	die $resp->status_line;
}

for( my $i = 0; $i < $timestopost; $i++) {
	warn "posting a bib number $i\n";
	#warn "xmldoc to post: $xmldoc\n";
	my $resp = $ua->post( $baseurl . '/new_bib' , 'Content-type' => 'text/xml', Content => $xmldoc );
	if( $resp->is_success ) {
		print "post to new_bib response:\n";
		print $resp->content;
	}
	else {
		die $resp->status_line;
	}
	sleep($timeout);
}


