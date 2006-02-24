#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Output;  # contains gettemplate
use C4::Biblio;
use CGI;
use C4::Koha;

my $query = new CGI;
my $op=$query->param("op");
my $dbh=C4::Context->dbh;

if ($op eq "export") {
	print $query->header('Content-Type: text/marc');
	my $start_bib = $query->param("start_bib");
	my $end_bib = $query->param("end_bib");
	my $format = $query->param("format");
	my $branch = $query->param("branch");
	my $start_callnumber = $query->param("start_callnumber");
	my $end_callnumber = $query->param("end_callnumber");
	my $limit = $query->param("limit");
	my $strsth;
	$strsth="select bibid from marc_biblio ";
	if ($start_bib && $end_bib) {
		$strsth.=" where biblionumber>=$start_bib and biblionumber<=$end_bib ";
	}elsif ($format) {
		if ($strsth=~/ where/){
			$strsth=~s/ where (.*)/,biblioitems where biblioitems.biblionumber=marc_biblio.biblionumber and biblioitems.itemtype=\'$format\' and $1/;
		}else {
			$strsth.=",biblioitems where biblioitems.biblionumber=marc_biblio.biblionumber and biblioitems.itemtype=\'$format\'";
		}
	} elsif ($branch) {
		if ($strsth=~/ where/){
			$strsth=~s/ where (.*)/,items where items.biblionumber=marc_biblio.biblionumber and items.homebranch=\'$branch\' and $1/;
		}else {
			$strsth.=",items where items.biblionumber=marc_biblio.biblionumber and items.homebranch=\'$branch\'";
		}
	} elsif ($start_callnumber && $end_callnumber) {
		$start_callnumber=~s/\*/\%/g;
		$start_callnumber=~s/\?/\_/g;
		$end_callnumber=~s/\*/\%/g;
		$end_callnumber=~s/\?/\_/g;
		if ($strsth=~/,items/){
			$strsth.=" and items.itemcallnumber between \'$start_callnumber\' and \'$end_callnumber\'";
		} else {
			if ($strsth=~/ where/){
				$strsth=~s/ where (.*)/,items where items.biblionumber=marc_biblio.biblionumber and items.itemcallnumber between \'$start_callnumber\' and \'$end_callnumber\' and $1/;
			}else {
				$strsth=~",items where items.biblionumber=marc_biblio.biblionumber and items.itemcallnumber between \'$start_callnumber\' and \'$end_callnumber\' ";
			}
		}
	}
	$strsth.=" order by marc_biblio.biblionumber ";
	$strsth.= "LIMIT 0,$limit " if ($limit);
	warn "requête marc.pl : ".$strsth;
	my $req=$dbh->prepare($strsth);
	$req->execute;
	while (my ($bibid) = $req->fetchrow) {
		my $record = MARCgetbiblio($dbh,$bibid);

		print $record->as_usmarc();
	}
} else {
	my $sth=$dbh->prepare("Select itemtype,description from itemtypes order by description");
	$sth->execute;
	my  @itemtype;
	my %itemtypes;
	push @itemtype, "";
	$itemtypes{''} = "";
	while (my ($value,$lib) = $sth->fetchrow_array) {
			push @itemtype, $value;
			$itemtypes{$value}=$lib;
	}
	
	my $CGIitemtype=CGI::scrolling_list( -name     => 'format',
							-values   => \@itemtype,
							-default  => '',
							-labels   => \%itemtypes,
							-size     => 1,
							-multiple => 0 );
	$sth->finish;
	
	my $branches = getallbranches;
	my @branchloop;
	foreach my $thisbranch (keys %$branches) {
# 			my $selected = 1 if $thisbranch eq $branch;
			my %row =(value => $thisbranch,
# 									selected => $selected,
									branchname => $branches->{$thisbranch}->{'branchname'},
							);
			push @branchloop, \%row;
	}
	
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "tools/export.tmpl",
					query => $query,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1, management => 1, tools => 1},
					debug => 1,
					});
	$template->param(branchloop=>\@branchloop,CGIitemtype=>$CGIitemtype);
	output_html_with_http_headers $query, $cookie, $template->output;
}

