#!/usr/bin/perl
use strict;
use ZOOM;

my $query="Introduction";
warn "QUERY : $query";
my $Zconn;
eval {
	$Zconn = new ZOOM::Connection('localhost:2100/Koha');
};
$Zconn->option(cqlfile => "/home/paul/koha.dev/head/zebra/pqf.properties");
my $q = new ZOOM::Query::CQL2RPN( $query, $Zconn);
# warn "Q : $q";
my $rs= $Zconn->search($q);
my $n = $rs->size()-1;
print "found ".($n+1)." results";
for my $i (0..$n) {
	my $rec = $rs->record($i);
	print $rec->render();
}
# 	warn "ERROR : ".$Zconn->errcode();
