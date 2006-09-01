#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use CGI;

use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Context;
use C4::Breeding;
use MARC::File::USMARC;
use ZOOM;
use Encode;;

my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error = $input->param('error');
my $oldbiblionumber=$input->param('oldbiblionumber');
$oldbiblionumber=0 unless $oldbiblionumber;
my $title = $input->param('title');
my $author = $input->param('author');
my $isbn = $input->param('isbn');
my $issn = $input->param('issn');
my $random = $input->param('random');
my $op=$input->param('op');
my $noconnection;
my $numberpending;
my $attr='';
my $term;
my $host;
my $server;
my $database;
my $port;
my $marcdata;
my $encoding=C4::Context->preference("marcflavour");
my @results;
my $count;
my $toggle;
my @breeding_loop = ();
my $record;
my $oldbiblio;
my $dbh = C4::Context->dbh;
my $errmsg;
my @serverloop=();
my @serverhost;
unless ($random) { # if random is a parameter => we're just waiting for the search to end, it's a refresh.
$random =rand(1000000000);
}


my ($template, $loggedinuser, $cookie);
if ($op ne "do_search"){

my $sth=$dbh->prepare("select id,host,checked from z3950servers  order by host");
$sth->execute();
while ($server=$sth->fetchrow_hashref) {
my %temploop;
$temploop{server}=$server->{host};
$temploop{id}=$server->{id};
$temploop{checked}=$server->{checked};
push (@serverloop, \%temploop);
}
($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "z3950/searchresult.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 1,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
$template->param(isbn=>$isbn, issn=>$issn,title=>$title,author=>$author,
						serverloop => \@serverloop,
						opsearch => "search",
						oldbiblionumber => $oldbiblionumber,
						);
output_html_with_http_headers $input, $cookie, $template->output;

}else{

my @id=$input->param('id');
my @oConnection;
my @oResult;
my $s=0;
							if ($isbn ne "/" || $issn ne "/") {
								$attr='1=7';
							$term=$isbn if ($isbn ne"/");
							$term=$issn if ($issn ne"/");
							} elsif ($title ne"/") {
								$attr='1=4 @attr 4=1  ';
							$term=$title;
							} elsif ($author ne "/") {
								$attr='1=1003';
							$term=$author;
							} 

							
my $query="\@attr $attr \"$term\"";	
			
  foreach my $servid ( @id){
  my $sth=$dbh->prepare("select name, port, db, host from z3950servers where id=?");
  $sth->execute($servid);

    while ($server=$sth->fetchrow_hashref) {
	my $noconnection=0;
	#$numberpending=1;
							
	my $option1=new ZOOM::Options();
	$option1->option(async=>1);
	$option1->option('elementSetName', 'F');
	$option1->option('databaseName',$server->{db})  ;
	$option1->option('preferredRecordSyntax', 'USMARC');
	 $oConnection[$s]=create ZOOM::Connection($option1);
	$oConnection[$s]->connect($server->{name}, $server->{port});
	$serverhost[$s]=$server->{host};
	$s++;
    }## while fetch

  }# foreach
my $nremaining = $s;
my $firstresult=1;
 for (my $z=0 ;$z<$s;$z++){
$oResult[$z] = $oConnection[$z]->search_pqf($query);

}
AGAIN:
 my $k;
my $event;
  while (($k = ZOOM::event(\@oConnection)) != 0) {
	$event = $oConnection[$k-1]->last_event();
# warn ("connection ", $k-1, ": event $event (", ZOOM::event_str($event), ")\n");
	last if $event == ZOOM::Event::ZEND;
   }
if ($k != 0) {
	$k--;
#warn $serverhost[$k];
	 my($error, $errmsg, $addinfo, $diagset) = $oConnection[$k]->error_x();
   	if ($error) {

	warn "$k $serverhost[$k] error $query: $errmsg ($error) $addinfo\n";
	goto MAYBE_AGAIN;
  	}
	
	my $numresults=$oResult[$k]->size() ;								
 									

	my $i;
	my $result='';
	if ($numresults>0){
		for ($i=0; $i<(($numresults<5) ? ($numresults) : (5)) ; $i++) {
			my $rec=$oResult[$k]->record($i); 										
			my $marcrecord;
			$marcdata = $rec->raw();											
			$marcrecord = MARC::File::USMARC::decode($marcdata);
			
			my $marcxml=$marcrecord->as_xml_record($marcrecord);
			$marcxml=Encode::encode('utf8',$marcxml);
			#$marcxml=Encode::decode('utf8',$marcxml);
			my $xmlhash=XML_xml2hash_onerecord($marcxml);						
		my $oldbiblio = XMLmarc2koha_onerecord($dbh,$xmlhash,'biblios');
				$oldbiblio->{isbn} =~ s/ |-|\.//g,
			$oldbiblio->{isbn} = substr($oldbiblio->{isbn},0,10);
			$oldbiblio->{issn} =~ s/ |-|\.//g,
			$oldbiblio->{issn} = substr($oldbiblio->{issn},0,10);

my ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported,$bid)=ImportBreeding($marcdata,1,$serverhost[$k],$encoding,$random);
			my %row_data;
 @breeding_loop = ();
	if ($i % 2) {
		$toggle="#ffffcc";
	} else {
		$toggle="white";
	}
	$row_data{toggle} = $toggle;
	$row_data{server} = $serverhost[$k];
	$row_data{isbn} = $oldbiblio->{isbn};

	$row_data{title} =$oldbiblio->{title};
	$row_data{author} = $oldbiblio->{author};
	$row_data{id} = $bid;
	$row_data{oldbiblionumber}=$oldbiblionumber;
	push (@breeding_loop, \%row_data);

						
}# $numresults
}#for up to 5 results
}# if $k !=0

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "z3950/searchresult.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 1,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
$numberpending=$nremaining-1;
$template->param(
						breeding_loop => \@breeding_loop,
#						 refresh=>($numberpending eq 0 ? "" : "search.pl?random=$random"),
						numberpending => $numberpending,
#						oldbiblionumber => $oldbiblionumber,
						);
output_html_with_http_headers $input, "", $template->output if $firstresult==1;
$firstresult++;
print  $template->output if $firstresult !=1;
MAYBE_AGAIN:
if (--$nremaining > 0) {
    goto AGAIN;
}
} ## if op=search
