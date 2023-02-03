#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2013 Vitor Fernandes , adapted for UNIMARC by George Veranis
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

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth qw( get_template_and_user );
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );


sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number ) = @_;
    my $res           = "
        <script type='text/javascript'>
            function Clic$field_number(event) {
                event.preventDefault();
                var defaultvalue;
                try {
                    defaultvalue = document.getElementById(event.data.id).value;
                } catch(e) {
                    alert('error when getting '+event.data.id);
                    return;
                }
                window.open(\"/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=unimarc_leader_authorities.pl&index=\" + event.data.id + \"&result=\"+defaultvalue,\"unimarc_field_000\",'width=1000,height=600,toolbar=false,scrollbars=yes');
            }
        </script>
";

    return ( $field_number, $res );
}


sub plugin {
    my ($input) = @_;
    my $index  = $input->param('index');
    my $result = $input->param('result');

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_leader_authorities.tt",
            query         => $input,
            type          => "intranet",
            flagsrequired   => { editcatalogue => '*' },
        }
    );
    $result = "     nz  a22     3  4500" unless $result;

    my $f5  = substr( $result, 5, 1 ); $f5   = wrapper( $f5 ) if $f5;
    my $f6  = substr( $result, 6, 1 ); $f6   = wrapper( $f6 ) if $f6;
    my $f9  = substr( $result, 9, 1 ); $f9   = wrapper( $f9 ) if $f9;
    my $f17 = substr( $result, 17, 1 ); $f17 = wrapper( $f17 ) if $f17;

    $template->param(
        index     => $index,
        "f5$f5"   => 1,
        "f6$f6"   => 1,
        "f9$f9"   => 1,
        "f17$f17" => 1,
);
    output_html_with_http_headers $input, $cookie, $template->output;
}
