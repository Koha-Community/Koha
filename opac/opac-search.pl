#!/usr/bin/perl
use strict;
require Exporter;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
use C4::Database;
use HTML::Template;
use C4::SearchMarc;
use C4::Acquisition;
use C4::Biblio;
my @spsuggest; # the array for holding suggestions
my $suggest;   # a flag to be set (if there are suggestions it's 1)
my $firstbiblionumber; # needed for directly sending user to first item
# use C4::Search;
my $totalresults;

my $itemtypelist;
my $brancheslist;
my $categorylist;
my $subcategorylist;
my $mediatypelist;
# added by Gavin 
my $totalresults;

my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("select description,itemtype from itemtypes order by description");
$sth->execute;
while (my ($description,$itemtype) = $sth->fetchrow) {
    $itemtypelist.="<option value=\"$itemtype\">$description</option>\n";
}
my $sth=$dbh->prepare("select description,subcategorycode from subcategorytable order by description");
$sth->execute;
while (my ($description,$subcategorycode) = $sth->fetchrow) {
    $subcategorylist.="<option value=\"$subcategorycode\">$description</option>\n";
}
my $sth=$dbh->prepare("select description,mediatypecode from mediatypetable order by description");
$sth->execute;
while (my ($description,$mediatypecode) = $sth->fetchrow) {
    $mediatypelist.="<option value=\"$mediatypecode\">$description</option>\n";
}
my $sth=$dbh->prepare("select description,categorycode from categorytable order by description");
$sth->execute;
while (my ($description,$categorycode) = $sth->fetchrow) {
    $categorylist .= '<input type="radio" name="categorylist" value="'.$categorycode.'">'.$description.'<br>';
}
my $sth=$dbh->prepare("select branchname,branchcode from branches order by branchname");
$sth->execute;

while (my ($branchname,$branchcode) = $sth->fetchrow) {
    $brancheslist.="<option value=\"$branchcode\">$branchname</option>\n";
}
my $query = new CGI;
my $op = $query->param("op");
my $type=$query->param('type');
my $avail=$query->param('avail');
my $itemtypesstring=$query->param("itemtypesstring");
$itemtypesstring =~s/"//g;
my @itemtypes = split ( /\|/, $itemtypesstring);
my $branchesstring=$query->param("branchesstring");
$branchesstring =~s/"//g;
my @branches = split (/\|/, $branchesstring);

my $startfrom=$query->param('startfrom');
$startfrom=0 if(!defined $startfrom);
my ($template, $loggedinuser, $cookie);
my $resultsperpage;
my $searchdesc;

if ($op eq "do_search") {
	my @marclist = $query->param('marclist');
	my @and_or = $query->param('and_or');
	my @excluding = $query->param('excluding');
	my @operator = $query->param('operator');
	my @value = $query->param('value');

	for (my $i=0;$i<=$#marclist;$i++) {
		if ($searchdesc) { # don't put the and_or on the 1st search term
			$searchdesc .= $and_or[$i]." ".$excluding[$i]." ".($marclist[$i]?$marclist[$i]:"*")." ".$operator[$i]." ".$value[$i]." " if ($value[$i]);
		} else {
			$searchdesc = $excluding[$i]." ".($marclist[$i]?$marclist[$i]:"*")." ".$operator[$i]." ".$value[$i]." " if ($value[$i]);
		}
	}
  if ($itemtypesstring ne ''){
    $searchdesc .= 'filtered by itemtypes ';
    $searchdesc .= join(" ",@itemtypes)
  }
  if ($branchesstring ne ''){
    $searchdesc .= ' in branches ';
    $searchdesc .= join(" ",@branches)
  }
	$resultsperpage= $query->param('resultsperpage');
	$resultsperpage = 19 if(!defined $resultsperpage);
	my $orderby = $query->param('orderby');
	my $desc_or_asc = $query->param('desc_or_asc');
	# builds tag and subfield arrays
	my @tags;

	foreach my $marc (@marclist) {
		if ($marc) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,$marc,'');
			if ($tag) {
				push @tags,$dbh->quote("$tag$subfield");
			} else {
				push @tags, $dbh->quote(substr($marc,0,4));
			}
		} else {
			push @tags, "";
		}
	}
	findseealso($dbh,\@tags);
    my $sqlstring;
    if ($itemtypesstring ne ''){
        $sqlstring = 'and (biblioitems.itemtype IN (';
        my $itemtypeloop=0;
        foreach my $itemtype (@itemtypes){
            if ($itemtype ne ''){
                if ($itemtypeloop != 0){
                    $sqlstring .=','
                }
                $sqlstring .= '"'.$itemtype.'"';
                $itemtypeloop++;
            }
        }
        $sqlstring .= '))'
    }
    if ($branchesstring ne ''){
        $sqlstring .= 'and biblio.biblionumber=items.biblionumber and (items.holdingbranch IN (';
        my $branchesloop=0;
        foreach my $branch (@branches){
            if ($branch ne ''){
                if ($branchesloop != 0){
                    $sqlstring .=','
                }
                $sqlstring .= '"'.$branch.'"';
                $branchesloop++;
            }
        }
        $sqlstring .= '))'
    }
  if ($avail){
    $sqlstring .= "and biblioitems.biblioitemnumber=items.biblioitemnumber and items.itemnumber !=issues.itemnumber and biblio.biblionumber !=reserves.biblionumber and (items.itemlost IS NULL or items.itemlost = 0) and (items.notforloan IS NULL or items.notforloan =0) and (items.wthdrawn IS NULL or items.wthdrawn =0) ";
  }
	my ($results,$total) = catalogsearch($dbh, \@tags,\@and_or,
										\@excluding, \@operator, \@value,
										$startfrom*$resultsperpage, $resultsperpage,$orderby,$desc_or_asc,$sqlstring);
	if ($total ==1) {
	if (C4::Context->preference("BiblioDefaultView") eq "normal") {
	     print $query->redirect("/cgi-bin/koha/opac-detail.pl?bib=".@$results[0]->{biblionumber});
	} elsif (C4::Context->preference("BiblioDefaultView") eq "MARC") {
	     print $query->redirect("/cgi-bin/koha/MARCdetail.pl?bib=".@$results[0]->{biblionumber});
	} else {
	     print $query->redirect("/cgi-bin/koha/ISBDdetail.pl?bib=".@$results[0]->{biblionumber});
	}
	exit;
	}
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "opac-searchresults.tmpl",
				query => $query,
				type => 'opac',
				authnotrequired => 1,
				debug => 1,
				});

	# multi page display gestion
	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ){
		$displaynext = 1;
	}

	my @field_data = ();

### Added by JF
## This next does a number of things:
# 1. It allows you to track all the searches made for stats, etc.
# 2. It fixes the 'searchdesc' variable problem by introducing
#         a. 'searchterms' which comes out as 'Keyword: neal stephenson'
#         b. 'phraseorterm' which comes out as 'neal stephenson'
#      both of these are useful for differen purposes ... I use searchterms
#      for display purposes and phraseorterm for passing the search terms
#      to an external source through a url (like a database search)
# 3. It provides the variables necessary for the spellchecking (look below for
#      how this is done
# 4.
 
$totalresults = $total;

## This formats the 'search results' string and populates
## the 'OPLIN' variable as well as the 'spellcheck' variable
## with appropriate values based on the user's search input

my $searchterms; #returned in place of searchdesc for 'results for search'
                 # as a string (can format if need be)

my @spphrases;
my $phraseorterm;
my %searchtypehash = ( # used only for the searchterms string formation
                        # and for spellcheck string
        '0' => 'keyword',
        '1' => 'title',
        '2' => 'author',
        '3' => 'subject',
        '4' => 'series',
        '5' => 'format',
        );

my @searchterm = $query->param('value');

for (my $i=0; $i <= $#searchterm; $i++) {
        my $searchtype = $searchtypehash{$i};
        push @spphrases, $searchterm[$i];
        if ($searchterms) { #don't put and in again
                if ($searchterm[$i]) {
                $phraseorterm.=$searchterm[$i];
                $searchterms.=" AND ".$searchtype." : \'".$searchterm[$i]."\'";
                }
        } else {
                if ($searchterm[$i]) {
                $phraseorterm.=$searchterm[$i];
                $searchterms.=$searchtype.": \'".$searchterm[$i]."\'";
                }
        }
}

# Spellchecck stuff ... needs to use above scheme but must change
# cgi script first
my $phrases = $query->param('value');
#my $searchterms = $query->param('value');
# warn "here is searchterms:".$searchterms;

# FIXME: should be obvious ;-)
#foreach my $phrases (@spphrases) {
$phrases =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
$phrases =~ s/(\Athe |\Aa |\Aan |)//g;
my $spchkphraseorterm = $phraseorterm;
        $spchkphraseorterm =~ tr/A-Z/a-z/;
        $spchkphraseorterm =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
        $spchkphraseorterm =~s/(\Aand-or |\Aand\/or |\Aanon |\Aan |\Aa |\Abut |\Aby |\Ade |\Ader |\Adr |\Adu|et |\Afor |\Afrom |\Ain |\Ainto |\Ait |\Amy |\Anot |\Aon |\Aor |\Aper |\Apt |\Aspp |\Ato |\Avs |\Awith |\Athe )/ /g;
        $spchkphraseorterm =~s/( and-or | and\/or | anon | an | a | but | by | de | der | dr | du|et | for | from | in | into | it | my | not | on | or | per | pt | spp | to | vs | with | the )/ /g;
 
        $spchkphraseorterm =~s/  / /g;
my $resultcount = $total;
my $ipaddress = $query->remote_host();
#

if (
#need to create a table to record the search info
#...FIXME: add the script name that creates the table
# 
my $dbhpop=DBI->connect("DBI:mysql:demosuggest:localhost","auth","YourPass")) {

# insert the search info query
my $insertpop = "INSERT INTO phrase_log(phr_phrase,phr_resultcount,phr_ip) VALUES(?,?,?)";

# grab spelling suggestions query
my $getsugg = "SELECT display FROM spellcheck WHERE strcmp(soundex(suggestion), soundex(?)) = 0 order by soundex(suggestion) limit 0,5";

#get spelling suggestions when there are no results
if ($resultcount eq 0) {
        my $sthgetsugg=$dbhpop->prepare($getsugg);
        $sthgetsugg->execute($spchkphraseorterm);
        while (my ($spsuggestion)=$sthgetsugg->fetchrow_array) {
#               warn "==>$spsuggestion";
                #push @spsuggest, +{ spsuggestion => $spsuggestion };
                my %line;
                $line{spsuggestion} = $spsuggestion;
                push @spsuggest,\%line;
                $suggest = 1;
        }
#       warn "==>".$#spsuggest;
        $sthgetsugg->finish;
}
# end of spelling suggestions

my $sthpop=$dbhpop->prepare($insertpop);

#$sthpop->execute($phrases,$resultcount,$ipaddress);
$sthpop->finish;
}
#
### end of tracking stuff  --  jmf at kados dot org
#
$template->param(suggest => $suggest );
$template->param( SPELL_SUGGEST => \@spsuggest );
$template->param( searchterms => $searchterms );
$template->param( phraseorterm => $phraseorterm );
#warn "here's the search terms: ".$searchterms;
#
### end of spelling suggestions
### /Added by JF

	for(my $i = 0 ; $i <= $#marclist ; $i++)
	{
		push @field_data, { term => "marclist", val=>$marclist[$i] };
		push @field_data, { term => "and_or", val=>$and_or[$i] };
		push @field_data, { term => "excluding", val=>$excluding[$i] };
		push @field_data, { term => "operator", val=>$operator[$i] };
		push @field_data, { term => "value", val=>$value[$i] };
	}

	my @numbers = ();

	if ($total>$resultsperpage)
	{
		for (my $i=1; $i<$total/$resultsperpage+1; $i++)
		{
			if ($i<16)
			{
	    		my $highlight=0;
	    		($startfrom==($i-1)) && ($highlight=1);
	    		push @numbers, { number => $i,
					highlight => $highlight ,
					searchdata=> \@field_data,
					startfrom => ($i-1)};
			}
    	}
	}

	my $from = $startfrom*$resultsperpage+1;
	my $to;

 	if($total < (($startfrom+1)*$resultsperpage))
	{
		$to = $total;
	} else {
		$to = (($startfrom+1)*$resultsperpage);
	}
	my $defaultview = 'BiblioDefaultView'.C4::Context->preference('BiblioDefaultView');
	$template->param(results => $results,
							startfrom=> $startfrom,
							displaynext=> $displaynext,
							displayprev=> $displayprev,
							resultsperpage => $resultsperpage,
							orderby => $orderby,
							startfromnext => $startfrom+1,
							startfromprev => $startfrom-1,
							searchdata=>\@field_data,
							total=>$total,
							from=>$from,
							to=>$to,
							numbers=>\@numbers,
							searchdesc=> $searchdesc,
							$defaultview => 1,
							suggestion => C4::Context->preference("suggestion"),
							virtualshelves => C4::Context->preference("virtualshelves"),
                itemtypelist => $itemtypelist,
              subcategorylist => $subcategorylist,
              brancheslist => $brancheslist,
              categorylist => $categorylist,
              mediatypelist => $mediatypelist,
              itemtypesstring => $itemtypesstring,
							);

} else {
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "opac-search.tmpl",
					query => $query,
					type => "opac",
					authnotrequired => 1,
				});
	
	
	$sth=$dbh->prepare("Select itemtype,description from itemtypes order by description");
	$sth->execute;
	my  @itemtype;
	my %itemtypes;
	push @itemtype, "";
	$itemtypes{''} = "";
	while (my ($value,$lib) = $sth->fetchrow_array) {
		push @itemtype, $value;
		$itemtypes{$value}=$lib;
	}
	
	my $CGIitemtype=CGI::scrolling_list( -name     => 'value',
				-values   => \@itemtype,
				-labels   => \%itemtypes,
				-size     => 1,
				-multiple => 0 );
	$sth->finish;
	
	my @branches;
	my @select_branch;
	my %select_branches;
	my ($count2,@branches)=branches();
	push @select_branch, "";
	$select_branches{''} = "";
	for (my $i=0;$i<$count2;$i++){
		push @select_branch, $branches[$i]->{'branchcode'};#
		$select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
	}
	my $CGIbranch=CGI::scrolling_list( -name     => 'value',
				-values   => \@select_branch,
				-labels   => \%select_branches,
				-size     => 1,
				-multiple => 0 );
	$sth->finish;
    
	$template->param(itemtypelist => $itemtypelist,
					CGIitemtype => $CGIitemtype,
					CGIbranch => $CGIbranch,
					suggestion => C4::Context->preference("suggestion"),
					virtualshelves => C4::Context->preference("virtualshelves"),
	);
}
# ADDED BY JF
if ($totalresults == 1){
    # if its a barcode search by definition we will only have one result.
    # And if we have a result
    # lets jump straight to the detail.pl page
    print $query->redirect("/cgi-bin/koha/opac-detail.pl?bib=$firstbiblionumber");
}
else {
  output_html_with_http_headers $query, $cookie, $template->output;
}
