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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Auth qw( get_template_and_user );
use CGI      qw ( -utf8 );
use C4::Context;

use C4::Search;
use C4::Output qw( output_html_with_http_headers );

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number ) = @_;
    my $function_name = "106" . ( int( rand(100000) ) + 1 );
    my $res           = "
<script>
function Clic$field_number(ev) {
        ev.preventDefault();
        defaultvalue=document.getElementById(ev.data.id).value;
        newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_106.pl&index=\" + ev.data.id + \"&result=\"+defaultvalue,\"unimarc_field_106\",'width=500,height=400,toolbar=false,scrollbars=yes');

}
</script>
";

    return ( $field_number, $res );
}

sub plugin {
    my ($input) = @_;
    my $index   = $input->param('index');
    my $result  = $input->param('result') || q{};

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_106.tt",
            query         => $input,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );
    my $f1 = substr( $result, 0, 1 );
    $template->param(
        index   => $index,
        "f1$f1" => $f1
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
