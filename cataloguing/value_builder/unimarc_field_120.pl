#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
#use warnings; FIXME - Bug 2505

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth;
use CGI;
use C4::Context;

use C4::Search;
use C4::Output;

=head1 FUNCTIONS

=head2 plugin_parameters

Other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name=$field_number;
my $res="
<script>
function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.getElementById(\"$field_number\").value;
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_120.pl&index=$field_number&result=\"+defaultvalue,\"unimarc_field_120\",'width=1200,height=750,toolbar=false,scrollbars=yes');

}
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
    = get_template_and_user({template_name => "cataloguing/value_builder/unimarc_field_120.tt",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => '*'},
			     debug => 1,
			     });
	my $f1 = substr($result,0,1);
	my $f2 = substr($result,1,1);
	my $f3 = substr($result,2,1);
	my $f4 = substr($result,3,1); $f4 = wrapper( $f4 ) if $f4;
	my $f5 = substr($result,4,1); $f5 = wrapper( $f5 ) if $f5;
	my $f6 = substr($result,5,1); $f6 = wrapper( $f6 ) if $f6;
	my $f7 = substr($result,6,1); $f7 = wrapper( $f7 ) if $f7;
	my $f8 = substr($result,7,2);
	my $f9 = substr($result,9,2); $f9 = wrapper( $f9 ) if $f9;
	my $f10 = substr($result,11,2); $f10 = wrapper( $f10 ) if $f10;
	$template->param(index => $index,
							"f1$f1" => 1,
							"f2$f2" => 1,
							"f3$f3" => 1,
							"f4$f4" => 1,
							"f5$f5" => 1,
							"f6$f6" => 1,
							"f7$f7" => 1,
							"f8$f8" => 1,
							"f9$f9" => 1,
							"f10$f10" => 1);
        output_html_with_http_headers $input, $cookie, $template->output;
}

1;
