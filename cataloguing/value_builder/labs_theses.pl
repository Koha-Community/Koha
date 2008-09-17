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

use C4::Output;
use C4::Context;
use C4::Auth;
use C4::Output;

use C4::Koha;

sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "328".(int(rand(100000))+1);
my $res="
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.f.field_value[i].value;
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=labs_theses.pl&cat_auth=LABTHE&index=\"+i+\"&result=\"+defaultvalue,\"unimarc field 328\",'width=700,height=700,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

return ($function_name,$res);
}

sub plugin {
	my ($input) = @_;
	my $dbh=C4::Context->dbh;
	my $query = new CGI;
	my $op = $query->param('op');
	my $cat_auth=$query->param('cat_auth');

	my $startfrom=$query->param('startfrom');
	$startfrom=0 if(!defined $startfrom);
	my ($template, $loggedinuser, $cookie);
	my $resultsperpage;
	my $search = $query->param('search');
	
	if ($op eq "do_search") {
	
		$resultsperpage= $query->param('resultsperpage');
		$resultsperpage = 19 if(!defined $resultsperpage);
# 		my $upperlimit=$startfrom+$resultsperpage;
		# builds tag and subfield arrays
		my $strquery = "SELECT authorised_value, lib from authorised_values where category = ? and lib like ?";
# 		$strquery .= " LIMIT $startfrom,$upperlimit";
		
		warn 'category : '.$cat_auth.' recherche :'.$search;
		warn "$strquery";
		$search=~s/\*/%/g;
		my $sth = $dbh->prepare($strquery);
		$sth->execute($cat_auth,$search);
		$search=~s/%/\*/g;
		
		
		my @results;
		my $total;
		while (my $data = $sth->fetchrow_hashref){
			my $libjs=$data->{'lib'};
			$libjs=~s#\'#\\\'#g;
			my $authjs=$data->{'authorised_value'};
			$authjs=~s#\'#\\\'#g;
			push @results, {'libjs'=>$libjs,
							'lib'=>$data->{'lib'},
							'authjs'=>$authjs,
							'auth_value'=>$data->{'authorised_value'}} 
							unless (($total<$startfrom) or ($total>$startfrom+$resultsperpage));
			$total++;
		}
		
		($template, $loggedinuser, $cookie)
			= get_template_and_user({template_name => "value_builder/labs_theses.tmpl",
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
	
		my @numbers = ();
	
		if ($total>$resultsperpage)
		{
			for (my $i=1; (($i<$total/$resultsperpage+1) && ($i<16)); $i++)
			{
					my $highlight=0;
					($startfrom==($i-1)) && ($highlight=1);
					push @numbers, { number => $i,
						highlight => $highlight ,
						search=> $search,
						startfrom => $resultsperpage*($i-1)};
			}
		}
	
		my $from = $startfrom+1;
		my $to;
	
		if($total < (($startfrom+1)*$resultsperpage))
		{
			$to = $total;
		} else {
			$to = (($startfrom+1)*$resultsperpage);
		}
 		$template->param(catresult => \@results,
 						cat_auth=>$cat_auth,
 						index => $query->param('index')."",
 								startfrom=> $startfrom,
								displaynext=> $displaynext,
								displayprev=> $displayprev,
								resultsperpage => $resultsperpage,
								startfromnext => $startfrom+$resultsperpage,
								startfromprev => $startfrom-$resultsperpage,
								search=>$search,
								total=>$total,
								from=>$from,
								to=>$to,
								numbers=>\@numbers,
								resultlist=>1
								);
	
	} else {
		($template, $loggedinuser, $cookie)
			= get_template_and_user({template_name => "value_builder/labs_theses.tmpl",
						query => $query,
						type => "intranet",
						authnotrequired => 1,
					});
		
		$template->param(
						'search'=>$query->param('search'),
		);
		$template->param(
						'index'=>''.$query->param('index')
		) if ($query->param('index'));
		warn 'index : '.$query->param('index');
		$template->param(
 						'cat_auth'=>$cat_auth
		) if ($cat_auth);
	}	
	output_html_with_http_headers $query, $cookie, $template->output ;
}

1;
