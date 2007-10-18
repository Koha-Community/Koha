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
use C4::Auth;
use CGI;
use C4::Context;

use C4::Search;
use C4::Output;
use C4::Authorities;

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= $field_number;
my $res="
<script>
function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(index) {
	defaultvalue=document.getElementById(\"$field_number\").value;
	newin=window.open(\"plugin_launcher.pl?plugin_name=unimarc_field_700_701_702.pl&index=$field_number&result=\"+defaultvalue,\"unimarc 700\",'width=700,height=300,toolbar=false,scrollbars=yes');

}
</script>
";

return ($function_name,$res);
}
sub plugin {
	my ($input) = @_;
	my $dbh = C4::Context->dbh;
#	my $input = new CGI;
	my $index= $input->param('index');
	my $result= $input->param('result');
	my $search_string= $input->param('search_string');
	my $op = $input->param('op');
	my $id = $input->param('id');
	my $insert = $input->param('insert');
	my @freelib;
	my %stdlib;
	my $select_list;
	my ($a,$b,$c,$f) ; # the 4 managed subfields.
	if ($op eq "add") {
		newauthority($dbh,'NP',$insert,$insert,'',1,'');
		$search_string=$insert;
	}
	if ($op eq "select") {
		my $sti = $dbh->prepare("select stdlib from bibliothesaurus where id=?");
		$sti->execute($id);
		my ($freelib_text) = $sti->fetchrow_array;
		$result = $freelib_text;
		# fill the 4 managed subfields
		my @arr = split //,$result;
		my $where = 1;
		foreach my $x (@arr) {
			next if ($x eq ')');
			if ($x eq ',') {
				$where=2;
				next;
			}
			if ($x eq '(') {
				if ($result =~ /.*;.*/) {
					$where=3;
				} else {
					$where=4;
				}
				next;
			}
			if ($x eq ';') {
				$where=4;
				next;
			}
			if ($where eq 1) {
				$a.=$x;
			}
			if ($where eq 2) {
				$b.=$x;
			}
			if ($where eq 3) {
				$c.=$x;
			}
			if ($where eq 4) {
				$f.=$x;
			}
		}
# remove trailing blanks
		$a=~ s/^\s+//g;
		$b=~ s/^\s+//g;
		$c=~ s/^\s+//g;
		$f=~ s/^\s+//g;
		$a=~ s/\s+$//g;
		$b=~ s/\s+$//g;
		$c=~ s/\s+$//g;
		$f=~ s/^s+$//g;
	}
	if ($search_string) {
	#	my $sti=$dbh->prepare("select id,freelib from bibliothesaurus where freelib like '".$search_string."%' and category ='$category'");
		my $sti=$dbh->prepare("select id,freelib from bibliothesaurus where match (category,freelib) AGAINST (?) and category ='NP'");
		$sti->execute($search_string);
		while (my $line=$sti->fetchrow_hashref) {
			$stdlib{$line->{'id'}} = "$line->{'freelib'}";
			push(@freelib,$line->{'id'});
		}
		$select_list= CGI::scrolling_list( -name=>'id',
				-values=> \@freelib,
				-default=> "",
				-size=>1,
				-multiple=>0,
				-labels=> \%stdlib
				);
	}
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "cataloguing/value_builder/unimarc_field_700_701_702.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { editcatalogue => 1},
					debug => 1,
					});
# builds collection list : search isbn and editor, in parent, then load collections from bibliothesaurus table
	$template->param(index => $index,
							result =>$result,
							select_list => $select_list,
							search_string => $search_string?$search_string:$result,
							a => $a,
							b => $b,
							c => $c,
							f => $f,);
        output_html_with_http_headers $input, $cookie, $template->output;
}

1;
