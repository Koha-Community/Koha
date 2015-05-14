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

function Focus$function_name(event) {
    if(!document.getElementById(event.data.id).value){
        document.getElementById(event.data.id).value = '     nz  a22     n  4500';
    }
    return 1;
}

function Click$function_name(event) {
    defaultvalue=document.getElementById(event.data.id).value;
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_leader_authorities.pl&index=\"+ event.data.id +\"&result=\"+defaultvalue,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

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
        {   template_name   => "cataloguing/value_builder/marc21_leader_authorities.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );
    $result = "     nz  a22     n  4500" unless $result;
    my $f5    = substr( $result, 5,  1 );
    my $f6    = substr( $result, 6,  1 );
    my $f7    = substr( $result, 7,  1 );
    my $f8    = substr( $result, 8,  1 );
    my $f9    = substr( $result, 9,  1 );
    my $f17   = substr( $result, 17, 1 );
    my $f2023 = substr( $result, 20, 4 );
    $template->param(
        index     => $index,
        "f5$f5"   => 1,
        "f6$f6"   => 1,
        "f7$f7"   => 1,
        "f8$f8"   => 1,
        "f9$f9"   => 1,
        "f17$f17" => 1,
        "f2023"   => $f2023,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };