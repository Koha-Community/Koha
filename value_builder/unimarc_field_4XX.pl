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
require Exporter;
use CGI;
use HTML::Template;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;
use C4::Database;
use C4::Biblio;
#use C4::SimpleMarc;
use C4::SearchMarc;
use C4::Acquisition;
use C4::Koha;
use MARC::Record;

sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "4XX".(int(rand(100000))+1);
my $res="
<script>
function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.f.field_value[i].value;
	newin=window.open(\"../plugin_launcher.pl?plugin_name=unimarc_field_4XX.pl&index=\"+i+\"&result=\"+defaultvalue,\"unimarc field 4\"+i+\"\",'width=700,height=700,toolbar=false,scrollbars=yes');

}
</script>
";

return ($function_name,$res);
}

sub plugin {
	my ($input) = @_;
	my %env;
	
	
	my $dbh=C4::Context->dbh;
	my $query = new CGI;
	my $op = $query->param('op');
	my $type=$query->param('type');
	warn "operation  ".$op;
	my $startfrom=$query->param('startfrom');
	$startfrom=0 if(!defined $startfrom);
	my ($template, $loggedinuser, $cookie);
	my $resultsperpage;
	my $searchdesc;
	
	if ($op eq "fillinput"){
		my $bibnum = $query->param('bibnum');
		my $index = $query->param('index');
		my $marcrecord;
# open template
		($template, $loggedinuser, $cookie)= get_template_and_user({template_name => "value_builder/unimarc_field_4XX.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			    });
		#get bibid
		my $bibid;
		my $req= $dbh->prepare("SELECT distinctrow bibid,biblionumber FROM `marc_biblio` WHERE biblionumber= ?");
		$req->execute($bibnum);
		($bibid,$bibnum) = $req->fetchrow;
		#warn "bibid :".$bibid;
		#get marc record
		$marcrecord = MARCgetbiblio($dbh,$bibid);
# 		warn "record : ".$marcrecord->as_formatted;
		
		my $subfield_value_9=$bibid;
		my $subfield_value_0;
		$subfield_value_0=$marcrecord->field('001')->data if $marcrecord->field('001');
		my $subfield_value_a;
		if ($marcrecord->field('200')){
			$subfield_value_a=$marcrecord->field('200')->subfield("f");
		} elsif ($marcrecord->field('700')){
			$subfield_value_a=$marcrecord->field('700')->subfield("a");
		} elsif ($marcrecord->field('701')){
			$subfield_value_a=$marcrecord->field('701')->subfield("a");
		}
		my $subfield_value_c = $marcrecord->field('210')->subfield("a") if ($marcrecord->field('210'));
		my $subfield_value_d = $marcrecord->field('210')->subfield("d") if ($marcrecord->field('210'));
		
		my $subfield_value_e= $marcrecord->field('205')->subfield("a") if ($marcrecord->field('205'));
		
		my $subfield_value_h; 
		if (($marcrecord->field('200')) && ($marcrecord->field('200')->subfield("h"))){
			$subfield_value_h = $marcrecord->field('200')->subfield("h") ;
		} elsif (($marcrecord->field('225')) && ($marcrecord->field('225')->subfield("h"))) {
			$subfield_value_h = $marcrecord->field('225')->subfield("h") ;
		} elsif (($marcrecord->field('500')) && ($marcrecord->field('500')->subfield("h"))) {
			$subfield_value_h = $marcrecord->field('500')->subfield("h") ;
		}
		
		my $subfield_value_i;
		if (($marcrecord->field('200')) && ($marcrecord->field('200')->subfield("i"))){
			$subfield_value_i = $marcrecord->field('200')->subfield("i") ;
		} elsif (($marcrecord->field('225')) && ($marcrecord->field('225')->subfield("i"))) {
			$subfield_value_i = $marcrecord->field('225')->subfield("i") ;
		} elsif (($marcrecord->field('500')) && ($marcrecord->field('500')->subfield("i"))) {
			$subfield_value_i = $marcrecord->field('500')->subfield("i") ;
		}

		my $subfield_value_p = $marcrecord->field('215')->subfield("a") if ($marcrecord->field('215'));
		
		my $subfield_value_t;
		if (($marcrecord->field('200')) && ($marcrecord->field('200')->subfield("a"))){
			$subfield_value_t = $marcrecord->field('200')->subfield("a") ;
		} elsif (($marcrecord->field('225')) && ($marcrecord->field('225')->subfield("a"))) {
			$subfield_value_t = $marcrecord->field('225')->subfield("a") ;
		} elsif (($marcrecord->field('500')) && ($marcrecord->field('500')->subfield("a"))) {
			$subfield_value_t = $marcrecord->field('500')->subfield("a") ;
		}
		
		my $subfield_value_u = $marcrecord->field('856')->subfield("u") if ($marcrecord->field('856'));
		
		my $subfield_value_v;
		if (($marcrecord->field('225')) && ($marcrecord->field('225')->subfield("v"))){
			$subfield_value_v = $marcrecord->field('225')->subfield("v") ;
		} elsif (($marcrecord->field('200')) && ($marcrecord->field('200')->subfield("h"))) {
			$subfield_value_v = $marcrecord->field('200')->subfield("h") ;
		}
		my $subfield_value_x = $marcrecord->field('011')->subfield("a") if ($marcrecord->field('011') and not (($marcrecord->field('011')->subfield("y")) or ($marcrecord->field('011')->subfield("z"))));
		my $subfield_value_y = $marcrecord->field('013')->subfield("a") if ($marcrecord->field('013'));
		if ($marcrecord->field('010')){
			$subfield_value_y = $marcrecord->field('010')->subfield("a");
		}
		$template->param(fillinput => 1,
						index => $query->param('index')."",
						bibid=>$bibid?$bibid:"",
						subfield_value_9=>$subfield_value_9,
						subfield_value_0=>$subfield_value_0,
						subfield_value_a=>$subfield_value_a,
						subfield_value_c=>$subfield_value_c,
						subfield_value_d=>$subfield_value_d,
						subfield_value_e=>$subfield_value_e,
						subfield_value_h=>$subfield_value_h,
						subfield_value_i=>$subfield_value_i,
						subfield_value_p=>$subfield_value_p,
						subfield_value_t=>$subfield_value_t,
						subfield_value_u=>$subfield_value_u,
						subfield_value_v=>$subfield_value_v,
						subfield_value_x=>$subfield_value_x,
						subfield_value_y=>$subfield_value_y,
						);
###############################################################	
	}elsif ($op eq "do_search") {
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
		
		my ($results,$total) = catalogsearch($dbh, \@tags,\@and_or,
											\@excluding, \@operator, \@value,
											$startfrom*$resultsperpage, $resultsperpage,$orderby, $desc_or_asc);
#		warn " biblio count : ".$total;
		
		($template, $loggedinuser, $cookie)
			= get_template_and_user({template_name => "value_builder/unimarc_field_4XX.tmpl",
					query => $query,
					type => 'intranet',
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
		$template->param(result => $results,
						index => $query->param('index')."",
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
								Search =>0
								);
	
	} else {
		($template, $loggedinuser, $cookie)
			= get_template_and_user({template_name => "value_builder/unimarc_field_4XX.tmpl",
						query => $query,
						type => "intranet",
						authnotrequired => 1,
					});
		
		
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
		
		my $CGIitemtype=CGI::scrolling_list( -name     => 'value',
					-values   => \@itemtype,
					-labels   => \%itemtypes,
					-size     => 1,
					-multiple => 0 );
		$sth->finish;
		
		my @branchloop;
		my @select_branch;
		my %select_branches;
		my $branches=getbranches;
		push @select_branch, "";
		$select_branches{''} = "";
		foreach my $thisbranch (keys %$branches){
			push @select_branch, $branches->{$thisbranch}->{'branchcode'};
			$select_branches{$branches->{$thisbranch}->{'branchcode'}} = $branches->{$thisbranch}->{'branchname'};
		}
		my $CGIbranch=CGI::scrolling_list( -name     => 'value',
					-values   => \@select_branch,
					-labels   => \%select_branches,
					-size     => 1,
					-multiple => 0 );
		$sth->finish;
		
		my $req = $dbh->prepare("select distinctrow left(publishercode,45) from biblioitems order by publishercode");
		$req->execute;
		my @select;
		push @select,"";
		while (my ($value) =$req->fetchrow) {
			push @select, $value;
		}
		my $CGIpublisher=CGI::scrolling_list( -name     => 'value',
					-id => 'publisher',
					-values   => \@select,
					-size     => 1,
					-multiple => 0 );
		
# 		my $sth=$dbh->prepare("select description,itemtype from itemtypes order by description");
# 		$sth->execute;
# 		while (my ($description,$itemtype) = $sth->fetchrow) {
# 			$classlist.="<option value=\"$itemtype\">$description</option>\n";
# 		}
# 		$sth->finish;
				
		$template->param(#classlist => $classlist,
						CGIitemtype => $CGIitemtype,
						CGIbranch => $CGIbranch,
						CGIPublisher => $CGIpublisher,
						index=>$query->param('index'),
						Search =>1,
		);
	}	
	output_html_with_http_headers $query, $cookie, $template->output ;
}

1;
