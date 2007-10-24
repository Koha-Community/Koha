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
use C4::Output;
use C4::Auth;
use CGI;
use C4::Search;
use C4::AuthoritiesMarc;
use C4::Context;
use C4::Biblio;


=head1 NAME

dictionnary.pl : script to search in biblio & authority an existing value

=head1 SYNOPSIS

useful when the user want to search a term before running a query. For example, to see if "computer" is used in the database

The parameter "marclist" tells which field is searched (title, author, subject, but could be anything else)

This script searches in both biblios & authority
* in biblio, the script search in all marc fields related to what the user is looking for (for example, if the dictionnary is used on "author", the script searches in biblio.author, but also in additional authors & any MARC field related to author (through the "seealso" MARC constraint)
* in authority, the script search everywhere. Thus, the accepted & rejected forms are found.

The script shows all results & the user can choose what he want, that is copied into search form.

=cut

my $input = new CGI;
my $field =$input->param('marclist');
#warn "field :$field";
my ($tablename, $kohafield)=split /./,$field;
#my $tablename=$input->param('tablename');
$tablename="biblio" unless ($tablename);
#my $kohafield = $input->param('kohafield');
my @search = $input->param('search');
# warn " ".$search[0];
my $index = $input->param('index');
# warn " index: ".$index;
my $op=$input->param('op');
if (($search[0]) and not ($op eq 'do_search')){
	$op='do_search';
}
my $script_name = 'catalogue/dictionary.pl';
my $query;
my $type=$input->param('type');
#warn " ".$type;

my $dbh = C4::Context->dbh;
my ($template, $loggedinuser, $cookie);

my $startfrom=$input->param('startfrom');
$startfrom=0 if(!defined $startfrom);
my $searchdesc;
my $resultsperpage;

#warn "Starting process";

if ($op eq "do_search") {
	#
	# searching in biblio
	#
	my $sth=$dbh->prepare("Select distinct tagfield,tagsubfield from marc_subfield_structure where kohafield = ?");
	$sth->execute("$field");
	my (@tags, @and_or, @operator, @excluding,@value);
	
 	while ((my $tagfield,my $tagsubfield,my $liblibrarian) = $sth->fetchrow) {
 		push @tags, $dbh->quote("$tagfield$tagsubfield");
 	}

	$resultsperpage= $input->param('resultsperpage');
	$resultsperpage = 19 if(!defined $resultsperpage);
	my $orderby = $input->param('orderby');

	findseealso($dbh,\@tags);

	my @results, my $total;
	my $strsth="select distinct subfieldvalue, count(marc_subfield_table.bibid) from marc_subfield_table,marc_word where marc_word.word like ? and marc_subfield_table.bibid=marc_word.bibid and marc_subfield_table.tagorder=marc_word.tagorder and marc_word.tagsubfield in ";
	my $listtags="(";
	foreach my $tag (@tags){
		$listtags .= $tag .",";
	}
	$listtags =~s/,$/)/;
	$strsth .= $listtags." and marc_word.tagsubfield=concat(marc_subfield_table.tag,marc_subfield_table.subfieldcode) group by subfieldvalue ";
# 	warn "search in biblio : ".$strsth;
	my $value = uc($search[0]);
	$value=~s/\*/%/g;
	$value.= "%" if not($value=~m/%/);
# 	warn " texte : ".$value;

	$sth=$dbh->prepare($strsth);
	$sth->execute($value);
	my $total;
	my @catresults;
	my $javalue;
	while (my ($value,$ctresults)=$sth->fetchrow) {
		# This $javalue is used for the javascript selectentry function (javalue for javascript value !)
		$javalue = $value;
		$javalue =~s/'/\\'/g;

		push @catresults,{value=> $value, 
						  javalue=> $javalue,
						  even=>($total-$startfrom*$resultsperpage)%2,
						  count=>$ctresults
						  } if (($total>=$startfrom*$resultsperpage) and ($total<($startfrom+1)*$resultsperpage));
		$total++;
	}
	

	my $strsth="Select distinct authtypecode from marc_subfield_structure where (";
	foreach my $listtags (@tags){
		my @taglist=split /,/,$listtags;
		foreach my $curtag (@taglist){
			$curtag =~s/\s+//;
			$strsth.="(tagfield='".substr($curtag,1,3)."' AND tagsubfield='".substr($curtag,4,1)."') OR";
		}
	}
	
	$strsth=~s/ OR$/)/;
	my $strsth = $strsth." and authtypecode is not NULL";
# 	warn $strsth;
	my $sth=$dbh->prepare($strsth);
	$sth->execute;
	
	#
	# searching in authorities
	#
	my @authresults;
	my $authnbresults;
	while ((my $authtypecode) = $sth->fetchrow) {
		my ($curauthresults,$nbresults) = SearchAuthorities([''],[''],[''],['contains'],
														\@search,$startfrom*$resultsperpage, $resultsperpage,$authtypecode);
		if (defined(@$curauthresults)) {
			for (my $i = 0; $i < @$curauthresults ;$i++) {
				@$curauthresults[$i]->{jamainentry} = @$curauthresults[$i]->{mainentry};
				@$curauthresults[$i]->{jamainentry} =~ s/'/\\'/g;
			}
		}
		push @authresults, @$curauthresults;
		$authnbresults+=$nbresults;
#		warn "auth : $authtypecode nbauthresults : $nbresults";
	}
	
	# 
	# OK, filling the template with authorities & biblio entries found.
	#
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "catalogue/dictionary.tmpl",
				query => $input,
				type => $type,
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	# multi page display gestion
	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ) {
		$displaynext = 1;
	}

	my @field_data = ();

	for(my $i = 0 ; $i <= $#tags ; $i++) {
		push @field_data, { term => "marclist", val=>$tags[$i] };
		push @field_data, { term => "and_or", val=>$and_or[$i] };
		push @field_data, { term => "excluding", val=>$excluding[$i] };
		push @field_data, { term => "operator", val=>$operator[$i] };
		push @field_data, { term => "value", val=>$value[$i] };
	}

	my @numbers = ();

	if ($total>$resultsperpage) {
		for (my $i=1; $i<$total/$resultsperpage+1; $i++) {
			if ($i<16) {
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
	$template->param(anindex => $input->param('index'));
	$template->param(result => \@results,
					 catresult=> \@catresults,
						search => $search[0],
						marclist =>$field,
						authresult => \@authresults,
						nbresults => $authnbresults,
						startfrom=> $startfrom,
						displaynext=> $displaynext,
						displayprev=> $displayprev,
						resultsperpage => $resultsperpage,
						startfromnext => $startfrom+1,
						startfromprev => $startfrom-1,
						searchdata=>\@field_data,
						total=>$total,
						from=>$from,
						to=>$to,
						numbers=>\@numbers,
						MARC_ON => C4::Context->preference("marc"),
						);

 } else {
 	($template, $loggedinuser, $cookie)
 		= get_template_and_user({template_name => "catalogue/dictionary.tmpl",
 				query => $input,
 				type => $type,
				authnotrequired => 0,
 				flagsrequired => {catalogue => 1},
 				debug => 1,
 				});
#warn "type : $type";
 
 }
$template->param(search => $search[0],
		marclist =>$field,
		type=>$type,
		anindex => $input->param('index'),
		);

# Print the page
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
