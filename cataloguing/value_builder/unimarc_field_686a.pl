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
use C4::Auth;
use CGI;
use C4::Context;

use C4::Search;
use C4::Output;

=head1 NAME

plugin unimarc_field_686a

=head1 SYNOPSIS

This plug-in deals with unimarc field 686a (

=head1 DESCRIPTION

=head1 FUNCTIONS

=over 2

=cut

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
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_686a.pl&result=\"+defaultvalue+\"&index=$field_number\",\"value_builder\",'width=700,height=600,toolbar=false,scrollbars=yes');

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

    my ($template, $loggedinuser, $cookie) = get_template_and_user(
        {
            template_name   => "cataloguing/value_builder/unimarc_field_686a.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );
	$template->param(index => $index,
							index2 => $index2,
							authtypecode => 'CLASSCD',
							);
        output_html_with_http_headers $input, $cookie, $template->output;
}

1;
