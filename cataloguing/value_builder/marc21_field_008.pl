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

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

# find today's date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); 

$year +=1900; $mon +=1;
my $dateentered = substr($year,2,2).sprintf ("%0.2d", $mon).sprintf ("%0.2d",$mday);
sub plugin_parameters {
	my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
	return "";
}

sub plugin_javascript {
	my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
	my $function_name= $field_number;
	my $res="
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {

	if ( document.getElementById(\"$field_number\").value ) {
	}
	else {
		document.getElementById(\"$field_number\").value='$dateentered' + 't        xxu||||| |||| 00| 0 eng d';
	}
    return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.getElementById(\"$field_number\").value;
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_008.pl&index=$field_number&result=\"+defaultvalue,\"unimarc field 100\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

	return ($function_name,$res);
}
sub plugin {
	my ($input) = @_;
	my $index= $input->param('index');
	my $result= $input->param('result');


	my $dbh = C4::Context->dbh;

	my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/value_builder/marc21_field_008.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });
#	$result = "      t        xxu           00  0 eng d" unless $result;
	$result = "$dateentered"."t        xxu||||| |||| 00| 0 eng d" unless $result;
	my $f1 = substr($result,0,6);
	my $f6 = substr($result,6,1);
	my $f710 = substr($result,7,4);
	my $f1114 = substr($result,11,4);
	my $f1517 = substr($result,15,3);
	my $f1821 = substr($result,18,4);
	my $f22 = substr($result,22,1);
	my $f23 = substr($result,23,1);
	my $f2427 = substr($result,24,4);
	my $f28 = substr($result,28,1);
	my $f29 = substr($result,29,1);
	my $f30 = substr($result,30,1);
	my $f31 = substr($result,31,1);
	my $f33 = substr($result,33,1);
	my $f34 = substr($result,34,1);
	my $f3537 = substr($result,35,3);
	my $f38 = substr($result,38,1);
	my $f39 = substr($result,39,1);

if ((!$f1) ||($f1 =~ m/ /)){
	$f1=$dateentered;
}

	$template->param(				index => $index,
							f1 => $f1,
							f6 => $f6,
							"f6$f6" => $f6,
							f710 => $f710,
							f1114 => $f1114,
							f1517 => $f1517,
							f1821 => $f1821,
							f22 => $f22,
							"f22$f22" => $f22,
							f23 => $f23,
                                                        "f23$f23" => $f23,
							f2427 => $f2427,
							"f24$f2427" => $f2427,
							f28 => $f28,
                                                        "f28$f28" => $f28,
							f29 => $f29,
                                                        "f29$f29" => $f29,
							f30 => $f30,
                                                        "f230$f30" => $f30,
							f31 => $f31,
                                                        "f31$f31" => $f31,
							f33 => $f33,
                                                        "f33$f33" => $f33,
							f34 => $f34,
                                                        "f34$f34" => $f34,
							f3537 => $f3537,
							f38 => $f38,
							"f38$f38" => $f38,
							f39 => $f39,
							"f39$f39" => $f39,
					);
        output_html_with_http_headers $input, $cookie, $template->output;
}

1;
