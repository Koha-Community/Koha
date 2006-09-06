#!/usr/bin/perl
# WARNING: 4-character tab stops here

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
use C4::Context;
use C4::Interface::CGI::Output;
use C4::AuthoritiesMarc;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Biblio;


my $query=new CGI;
my $op = $query->param('op');
my $authtypecode = $query->param('authtypecode');
my $dbh = C4::Context->dbh;
my $mergefrom=$query->param('mergefrom');
my $mergeto=$query->param('mergeto');
my $startfrom=$query->param('startfrom');
my $authid=$query->param('authid');
$startfrom=0 if(!defined $startfrom);
my ($template, $loggedinuser, $cookie);
my $resultsperpage;

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (sort { $authtypes->{$a} <=> $authtypes->{$b} } keys %$authtypes) {
	my $selected = 1 if $thisauthtype eq $authtypecode;
	my %row =(value => $thisauthtype,
				selected => $selected, 
				authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
			);
	push @authtypesloop, \%row;
}


if ($op eq "do_search") {
	my @marclist = $query->param('marclist');
	
	my @operator = $query->param('operator');
	my @value = $query->param('value');

	$resultsperpage= $query->param('resultsperpage');
	$resultsperpage = 10 unless $resultsperpage;
	my @tags;
	my ($results,$total) = authoritysearch($dbh, \@marclist, \@operator, \@value,$startfrom*$resultsperpage, $resultsperpage,$authtypecode) ;
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/searchresultlist.tmpl",
				query => $query,
				type => 'intranet',
				authnotrequired => 0,
				authtypecode=> $authtypecode,
				flagsrequired => {borrowers => 1},
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	# multi page display gestion
	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ){
		$displaynext = 1;
	}

	my @field_data = ();

	# we must get parameters once again. Because if there is a mainentry, it has been replaced by something else during the search, thus the links next/previous would not work anymore 
	my @marclist_ini = $query->param('marclist');
	for(my $i = 0 ; $i <= $#marclist ; $i++)
	{
		push @field_data, { term => "marclist", val=>$marclist_ini[$i] };
		push @field_data, { term => "operator", val=>$operator[$i] };
		push @field_data, { term => "value", val=>$value[$i] };
	}

	my @numbers = ();

	if ($total>$resultsperpage)
	{
		for (my $i=1; $i<$total/$resultsperpage+1; $i++)
		{
			if ($i<31)
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
	$template->param(result => $results) if $results;
	$template->param(
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
							authtypecode=>$authtypecode,
							);

} elsif ($op eq "delete") {

	&AUTHdelauthority($dbh,$authid);

	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/authorities-home.tmpl",
				query => $query,
				type => 'intranet',
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});


}elsif ($op eq "merge") {


	my $MARCfrom = XMLgetauthorityhash($dbh,$mergefrom);
	my $MARCto = XMLgetauthorityhash($dbh,$mergeto);
	merge($dbh,$mergefrom,$MARCfrom,$mergeto,$MARCto);
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/authorities-home.tmpl",
				query => $query,
				type => 'intranet',
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
}else {
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/authorities-home.tmpl",
				query => $query,
				type => 'intranet',
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

}



$template->param(authtypesloop => \@authtypesloop);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
