#!/usr/bin/perl
use strict;
require Exporter;
use C4::Search;
use C4::Auth;
use C4::Serials; #uses getsubscriptionfrom biblionumber
use C4::Interface::CGI::Output;
use CGI;
use C4::Biblio;
use C4::Context;

use Encode;

my $dbh=C4::Context->dbh;
my $query=new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "catalogue/detail.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my $biblionumber=$query->param('biblionumber');
$template->param(biblionumber => $biblionumber);
my $retrieve_from=C4::Context->preference('retrieve_from');
my ($record,$frameworkcode);
my @itemrecords;
my @items;
if ($retrieve_from eq "zebra"){
($record,@itemrecords)=ZEBRAgetrecord($biblionumber);
}else{
 $record =XMLgetbiblio($dbh,$biblionumber);
$record=XML_xml2hash_onerecord($record);
my @itemxmls=XMLgetallitems($dbh,$biblionumber);
	foreach my $itemrecord(@itemxmls){
	my $itemhash=XML_xml2hash_onerecord($itemrecord);
	push @itemrecords, $itemhash;
	}
}	

my $dat = XMLmarc2koha_onerecord($dbh,$record,"biblios");
my $norequests = 1;
foreach my $itemrecord (@itemrecords){

my $item= XMLmarc2koha_onerecord($dbh,$itemrecord,"holdings");
$item=ItemInfo($dbh,$item);
$item->{itemtype}=$dat->{itemtype};
  $norequests = 0 unless $item->{'notforloan'};
   $item->{$item->{'publictype'}} = 1; ## NOT sure what this is kept from old db probably useless now
push @items,$item;
}

my $subscriptionsnumber = GetSubscriptionsFromBiblionumber($biblionumber);

$dat->{'count'}=@items;
$template->param(count =>$dat->{'count'});
$template->param(norequests => $norequests);

  ## get notes subjects and URLS from MARC record
	
	my $marcflavour = C4::Context->preference("marcflavour");
	my $marcnotesarray = &getMARCnotes($dbh,$record,$marcflavour);
	my $marcsubjctsarray = &getMARCsubjects($dbh,$record,$marcflavour);
	my $marcurlssarray = &getMARCurls($dbh,$record,$marcflavour);
	$template->param(MARCURLS => $marcurlssarray);
	$template->param(MARCNOTES => $marcnotesarray);
	$template->param(MARCSUBJCTS => $marcsubjctsarray);


my @results = ($dat,);

my $resultsarray=\@results;
my $itemsarray=\@items;


$template->param(BIBLIO_RESULTS => $resultsarray,
				ITEM_RESULTS => $itemsarray,
				subscriptionsnumber => $subscriptionsnumber,
);

output_html_with_http_headers $query, $cookie, $template->output;
