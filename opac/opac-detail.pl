#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Bull; #uses getsubscriptionfrom biblionumber
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Biblio;
use C4::SearchMarc;

my $query=new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-detail.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my $biblionumber=$query->param('bib');
$template->param(biblionumber => $biblionumber);


# change back when ive fixed request.pl
my @items                                 = &ItemInfo(undef, $biblionumber, 'opac');
my $dat                                   = &bibdata($biblionumber);
my ($authorcount, $addauthor)             = &addauthor($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
my ($websitecount, @websites)             = &getwebsites($biblionumber);
my $subscriptionid = getsubscriptionfrombiblionumber($biblionumber);

$dat->{'count'}=@items;

$dat->{'additional'}=$addauthor->[0]->{'author'};
for (my $i = 1; $i < $authorcount; $i++) {
        $dat->{'additional'} .= "|" . $addauthor->[$i]->{'author'};
} # for

my $norequests = 1;
foreach my $itm (@items) {
    $norequests = 0 unless $itm->{'notforloan'};
    $itm->{$itm->{'publictype'}} = 1;
}

$template->param(norequests => $norequests);

  ## get notes and subjects from MARC record
my $marc = C4::Context->preference("marc");
if ($marc eq "yes") {
	my $dbh = C4::Context->dbh;
	my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);
	my $marcflavour = C4::Context->preference("marcflavour");
	my $marcnotesarray = &getMARCnotes($dbh,$bibid,$marcflavour);
	my $marcsubjctsarray = &getMARCsubjects($dbh,$bibid,$marcflavour);

	$template->param(MARCNOTES => $marcnotesarray);
	$template->param(MARCSUBJCTS => $marcsubjctsarray);
}

my @results = ($dat,);

my $resultsarray=\@results;
my $itemsarray=\@items;
my $webarray=\@webbiblioitems;
my $sitearray=\@websites;

$template->param(BIBLIO_RESULTS => $resultsarray,
				ITEM_RESULTS => $itemsarray,
				WEB_RESULTS => $webarray,
				SITE_RESULTS => $sitearray,
				subscriptionid => $subscriptionid,
);

output_html_with_http_headers $query, $cookie, $template->output;
