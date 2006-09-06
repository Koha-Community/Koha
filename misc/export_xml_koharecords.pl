#!/usr/bin/perl
## This script allows you to export a rel_2_2 bibliographic db in 
#MARC21 format from the command line.
#
use strict;
require Exporter;
use C4::Auth;
use C4::Biblio;
use XML::Simple;
use Getopt::Long;

my ( $out_marc_file, $check) ;
GetOptions(
    'file:s'    => \$out_marc_file,
    'c:s' => \$check,
   
);
### Usage 
## export_xml_koharecords -file somefilename -c 1
## use the -c flag if you want to check whether you xml is proper or not. Advisable but very slow
open(OUT,">" ,$out_marc_file) or die $!;

	my $dbh= C4::Context->dbh;

	my $sth;

		$sth=$dbh->prepare("select biblionumber,marcxml from biblio  order by biblionumber ");
my $sth2=$dbh->prepare("select marcxml from items where biblionumber =?");
		$sth->execute();
	
my $header=&collection_header;
	print OUT '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	print OUT $header;
	while (my ($biblionumber,$marcxml) = $sth->fetchrow) {
my $hash;
if ($check){
	eval {
	 $hash=XMLin($marcxml);
	}; ### is it a proper xml? broken xml may crash ZEBRA- slow but safe


	if ($@){
warn $biblionumber;
	next;
	}
}
		print OUT "<koharecord>\n";
		print OUT $marcxml;
		print OUT "<holdings>";
	$sth2->execute($biblionumber);
		while (my ($itemxml)=$sth2->fetchrow){
if ($check){
	eval {
	   $hash=XMLin($itemxml);
	}; ### is it a proper xml? broken xml may crash ZEBRA- slow but safe

	if ($@){
warn $biblionumber;
	next;
	}
}

		print OUT $itemxml;
		}
	print OUT "</holdings></koharecord>\n";
	}
	print OUT "</kohacollection>\n";
close(OUT);

sub collection_header {
####  this one is for koha collection 
    my $format = shift;
    my $enc = shift || 'UTF-8';
    return( <<KOHA_XML_HEADER );

<kohacollection xmlns:marc="http://loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://library.neu.edu.tr/kohanamespace/koharecord.xsd">
KOHA_XML_HEADER
}