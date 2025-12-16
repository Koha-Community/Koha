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

use strict;

#use warnings; FIXME - Bug 2505

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth                    qw( get_template_and_user );
use CGI                         qw ( -utf8 );
use C4::Context;

use C4::Search;
use C4::Output qw( output_html_with_http_headers );

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number ) = @_;
    my $res = "
    <script>
    function Clic$field_number(ev) {
            ev.preventDefault();
            defaultvalue=document.getElementById(ev.data.id).value;
            window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_110.pl&index=\" + ev.data.id + \"&result=\"+defaultvalue,\"unimarc_field_110\",'width=700,height=600,toolbar=false,scrollbars=yes');

    }
    </script>
    ";

    return ( $field_number, $res );
}

sub plugin {
    my ($input) = @_;
    my $index   = $input->param('index');
    my $result  = $input->param('result');

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_110.tt",
            query         => $input,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );
    my $f1 = substr( $result, 0, 1 );
    $f1 = wrapper($f1) if $f1;
    my $f2 = substr( $result, 1, 1 );
    $f2 = wrapper($f2) if $f2;
    my $f3 = substr( $result, 2, 1 );
    $f3 = wrapper($f3) if $f3;
    my $f4 = substr( $result, 3, 1 );
    $f4 = wrapper($f4) if $f4;
    my $f5 = substr( $result, 4, 3 );
    my $f6 = substr( $result, 7, 1 );
    $f6 = wrapper($f6) if $f6;
    my $f7 = substr( $result, 8, 1 );
    $f7 = wrapper($f7) if $f7;
    my $f8 = substr( $result, 9, 1 );
    $f8 = wrapper($f8) if $f8;
    my $f9 = substr( $result, 10, 1 );
    $f9 = wrapper($f9) if $f9;

    $template->param(
        index   => $index,
        "f1$f1" => 1,
        "f2$f2" => 1,
        "f3$f3" => 1,
        "f4$f4" => 1,
        f5      => $f5,
        "f6$f6" => 1,
        "f7$f7" => 1,
        "f8$f8" => 1,
        "f9$f9" => 1
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
