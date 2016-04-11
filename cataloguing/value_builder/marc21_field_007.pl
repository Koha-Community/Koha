#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

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

use Modern::Perl;

use C4::Auth;
use CGI qw ( -utf8 );
use C4::Context;

use C4::Search;
use C4::Output;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my $res           = "
<script type=\"text/javascript\">
//<![CDATA[

function Click$function_name(event) {
    defaultvalue=document.getElementById(event.data.id).value;
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_007.pl&index=\"+ event.data.id +\"&result=\"+defaultvalue,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $index   = $input->param('index');
    my $result  = $input->param('result');

    my $dbh = C4::Context->dbh;

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/marc21_field_007.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );

    $result = "ta" unless $result;
    my $pad_length = 23 - length $result;
    my @fvalues = split //, $result;
    if ($pad_length>0) {
        push @fvalues, (undef)x($pad_length);
    }
    my @fnames = map { "f$_" } (0..22);

    #FIXME:  Two of the material types treat position 06, 07, and 08 as a single
    #three-char field.  This script works fine for creating values and sending them
    #back to the MARC, but if there is already a value in the 007, it won't send
    #it properly to the value builder for those two instances.  Not sure how to solve.
    $template->param( index => $index );
    foreach my $count ( 0..22 ) {
        if (defined $fvalues[$count]) {
            # template uses f##pipe variables.
            my $key2;
            if ($fvalues[$count] eq q{|}) {
                $key2 = $fnames[$count] . 'pipe';
            }
            else {
                $key2 = $fnames[$count] . $fvalues[$count];
            }
            $template->param(
                $fnames[$count] => $fvalues[$count],
                $key2           => $fvalues[$count]
            );
        }
    }
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
