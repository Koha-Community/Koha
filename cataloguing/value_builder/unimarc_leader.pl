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

use Modern::Perl;

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth qw( get_template_and_user );
use CGI qw ( -utf8 );
use C4::Context;

use C4::Search;
use C4::Output qw( output_html_with_http_headers );

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number ) = @_;
    my $function_name = $field_number;
    my $res           = "
<script>
function Blur$function_name(event) {
    var leader_length = document.getElementById(event.data.id).value.length;
    if (leader_length != 24 && leader_length !=0) {
        alert(_('leader has an incorrect size: ' + leader_length + ' instead of 24 chars'));
    }
}

function Clic$function_name(event) {
    event.preventDefault();
    defaultvalue=document.getElementById(event.data.id).value;
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_leader.pl&index=\" + event.data.id + \"&result=\"+defaultvalue,\"unimarc_field_100\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
</script>
";

    return ( $function_name, $res );
}


sub plugin {
    my ($input) = @_;
    my $index   = $input->param('index');
    my $result  = $input->param('result');
    my $dbh     = C4::Context->dbh;

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "cataloguing/value_builder/unimarc_leader.tt",
            query           => $input,
            type            => "intranet",
            flagsrequired   => { editcatalogue => '*' },
        }
    );
    $result = "     nam         3       " unless $result;
    my $f5  = substr( $result, 5,  1 ); $f5  = wrapper( $f5 ) if $f5;
    my $f6  = substr( $result, 6,  1 ); $f6  = wrapper( $f6 ) if $f6;
    my $f7  = substr( $result, 7,  1 ); $f7  = wrapper( $f7 ) if $f7;
    my $f8  = substr( $result, 8,  1 ); $f8  = wrapper( $f8 ) if $f8;
    my $f9  = substr( $result, 9,  1 );
    my $f17 = substr( $result, 17, 1 ); $f17 = wrapper( $f17 ) if $f17;
    my $f18 = substr( $result, 18, 1 ); $f18 = wrapper( $f18 ) if $f18;
    my $f19 = substr( $result, 19, 1 );

    $template->param(
        index     => $index,
        "f5$f5"   => 1,
        "f6$f6"   => 1,
        "f7$f7"   => 1,
        "f8$f8"   => 1,
        "f9$f9"   => 1,
        "f17$f17" => 1,
        "f18$f18" => 1,
        "f19$f19" => 1,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
