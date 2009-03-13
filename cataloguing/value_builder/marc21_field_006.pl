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

sub plugin_parameters {
    my ($dbh, $record, $tagslib, $i, $tabloop) = @_;
    return "";
}

sub plugin_javascript {
    my ($dbh, $record, $tagslib, $field_number, $tabloop) = @_;
    my $function_name = $field_number;
    my $res           = "
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.getElementById(\"$field_number\").value;
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_006.pl&index=$field_number&result=\"+defaultvalue,\"unimarc field 100\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

    return ($function_name, $res);
}

sub plugin {
    my ($input) = @_;
    my $index   = $input->param('index');
    my $result  = $input->param('result');

    my $dbh = C4::Context->dbh;

    my ($template, $loggedinuser, $cookie) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/marc21_field_006.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => 1 },
            debug           => 1,
        }
    );
    $result = "a|||||r|||| 00| 0 " unless $result;

    #	$result = "a     r     00  0 " unless $result;
    my $f0   = substr($result, 0,  1);
    my $f014 = substr($result, 1,  4);
    my $f5   = substr($result, 5,  1);
    my $f6   = substr($result, 6,  1);
    my $f710 = substr($result, 7,  4);
    my $f11  = substr($result, 11, 1);
    my $f12  = substr($result, 12, 1);
    my $f13  = substr($result, 13, 1);
    my $f14  = substr($result, 14, 1);
    my $f15  = substr($result, 15, 1);
    my $f16  = substr($result, 16, 1);
    my $f17  = substr($result, 17, 1);

    $template->param(
        index       => $index,
        f0          => $f0,
        "f0$f0"     => $f0,
        f014        => $f014,
        "f014$f014" => $f014,
        f5          => $f5,
        "f5$f5"     => $f5,
        f6          => $f6,
        "f6$f6"     => $f6,
        f710        => $f710,
        "f710$f710" => $f710,
        f11         => $f11,
        "f11$f11"   => $f11,
        f12         => $f12,
        "f12$f12"   => $f12,
        f13         => $f13,
        "f13$f13"   => $f13,
        f14         => $f14,
        "f14$f14"   => $f14,
        f15         => $f15,
        "f15$f15"   => $f15,
        f16         => $f16,
        "f16$f16"   => $f16,
        f17         => $f17,
        "f17$f17"   => $f17,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
