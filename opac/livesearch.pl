#!/usr/bin/perl -w
#use C4::Context;
#use Apache::DBI;
use CGI;
use C4::Context;

my $cgi = new CGI;
my $zconn=C4::Context->Zconn("biblioserver");

binmode(STDOUT, "utf8"); #output as utf8

print $cgi->header( -type =>'text/xml' );

#my $dbh=DBI->connect("DBI:mysql:demosuggest:localhost","sugg","Free2cirC");
#my $dbh = C4::Context->dbh;

my $word = $cgi->param('value');


if ($word) {
	# strip out bad stuff -- this takes too long!
	$word =~ tr/A-Z/a-z/;
        $word =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
        $word =~s/  / /g;	
#	$word =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\Athe |\Aa |\Aan )//g;
	#$word  .= "\%";
	#$word = "&quot;".$word."&quot;";
	my $query = "\"$word\"";
	if ($query =~ / /) {
		$query = "\@attr 6=2 $query";
	}
	warn "$query";
	my $result;
	eval {
		my $zoom_query_obj = new ZOOM::Query::PQF($query);
		$result = $zconn->scan($zoom_query_obj);
	};
	if ($@) {
		die "error connecting to Zebra".$@;
	}
	my $numresults = 0 | $result->size() if  ($result);
	my $outstring="<?xml version='1.0' encoding='utf-8'  ?>";
        $outstring.="<ul class=\"LSRes\">";

	for ( my $i=1; $i<=10; $i++){
		my ($suggest,$count) = $result->term($i-1);
		my $length=length($suggest);
		$query=$suggest;
#		$query =~ s/(\'s|&|\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/|)//g;
		$outstring.="<li class=\"LSRow\" onmouseover=\"liveSearchHover(this)\" onclick=\"liveSearchClicked(this)\"><a href="."\"/cgi-bin/koha/opac-zoomsearch.pl?op=get_results&amp;cql_query=&quot;$query&quot;\">\n$suggest";


		$outstring.="\n</a>\n<span class=\"LSResRight\">$count results</span></li>";
	}
	$outstring.="</ul>";
	print $outstring;
}

