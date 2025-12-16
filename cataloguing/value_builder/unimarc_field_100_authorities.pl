#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2013 Vitor Fernandes
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

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth                    qw( get_template_and_user );
use CGI                         qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number ) = @_;
    my $res = "
        <script>
            function Clic$field_number(event) {
                event.preventDefault();
                const i = event.data.id;
                var defaultvalue;
                try {
                    defaultvalue = document.getElementById(i).value;
                } catch(e) {
                    alert('error when getting '+i);
                    return;
                }
                window.open(\"/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_100_authorities.pl&index=\"+i+\"&result=\"+defaultvalue,\"unimarc_field_100\",'width=1000,height=600,toolbar=false,scrollbars=yes');
            }
        </script>
";

    return ( $field_number, $res );
}

sub plugin {
    my ($input) = @_;
    my $index   = $input->param('index');
    my $result  = $input->param('result');

    my $defaultlanguage = C4::Context->preference("UNIMARCField100Language");
    $defaultlanguage = "fre" if ( !$defaultlanguage || length($defaultlanguage) != 3 );

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_100_authorities.tt",
            query         => $input,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );
    $result = "        a" . $defaultlanguage . "y50      ba0" unless $result;
    my $f1 = substr( $result, 0, 8 );
    if ( $f1 eq '        ' ) {
        my @today = Date::Calc::Today();
        $f1 = $today[0] . sprintf( '%02s', $today[1] ) . sprintf( '%02s', $today[2] );
    }

    my $f2 = substr( $result, 8, 1 );
    $f2 = wrapper($f2) if $f2;
    my $f3 = substr( $result, 9,  3 );
    my $f4 = substr( $result, 12, 1 );
    $f4 = wrapper($f4) if $f4;
    my $f5 = substr( $result, 13, 2 );
    $f5 = wrapper($f5) if $f5;
    my $f6 = substr( $result, 15, 2 );
    $f6 = wrapper($f6) if $f6;
    my $f7 = substr( $result, 17, 4 );
    $f7 = wrapper($f7) if $f7;
    my $f8 = substr( $result, 21, 2 );
    $f8 = wrapper($f8) if $f8;
    my $f9 = substr( $result, 23, 1 );
    $f9 = wrapper($f9) if $f9;

    $template->param(
        index   => $index,
        f1      => $f1,
        "f2$f2" => 1,
        f3      => $f3,
        "f4$f4" => 1,
        "f5$f5" => 1,
        "f6$f6" => 1,
        f7      => $f7,
        "f8$f8" => 1,
        "f9$f9" => 1,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
