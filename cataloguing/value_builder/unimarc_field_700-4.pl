#!/usr/bin/perl

# written 10/5/2002 by Paul

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

=head1 NAME

plugin unimarc_field_700-4

=head1 SYNOPSIS

This plug-in deals with unimarc field 700-4 (

=head1 DESCRIPTION

=head1 FUNCTIONS

=over 2

=cut

sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= $field_number;
my $res  = "
<script>
function Focus$function_name(index) {
	return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(subfield_managed) {
	defaultvalue=document.getElementById(\"$field_number\").value;
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_700-4.pl&result=\"+defaultvalue+\"&index=$field_number\",\"value builder\",'width=500,height=400,toolbar=false,scrollbars=yes');

}
</script>
";

return ($function_name,$res);
}

sub plugin {
my ($input) = @_;
	my $index= $input->param('index');
	my $index2= $input->param('index2');
	$index2=-1 unless($index2);
	my $result= $input->param('result');


	my $dbh = C4::Context->dbh;

	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "cataloguing/value_builder/unimarc_field_700-4.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {editcatalogue => 1},
					debug => 1,
					});
	$template->param(index => $index,
							index2 => $index2,
							"f1_$result" => "f1_".$result,
							);
        output_html_with_http_headers $input, $cookie, $template->output;
}

1;
