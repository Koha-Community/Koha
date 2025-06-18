#!/usr/bin/perl

# Copyright 2014 Rijksmuseum
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

use Date::Calc;

use Koha::Util::FrameworkPlugin qw(wrapper);
use C4::Auth                    qw( get_template_and_user );
use CGI                         qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Data::Dumper;

my $builder = sub {
    my $params = shift;
    my $id     = $params->{id};

    return qq|
<script>

function Click$id(event) {
    var fieldvalue=\$('#'+event.data.id).val();
    window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_181b.pl&index=\"+event.data.id+\"&result=\"+fieldvalue,\"tag_editor\",'width=700,height=700,toolbar=false,scrollbars=yes');
    return false; /* prevents scrolling */
}
</script>|;
};

my $launcher = sub {
    my $params = shift;
    my $cgi    = $params->{cgi};
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_181b.tt",
            query         => $cgi,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );
    my $results = scalar $cgi->param('result');
    $template->param(
        index  => scalar $cgi->param('index'),
        result => $results,
    );

    # Return the result of the position in the string, ex: abcde = 1=a, 2=b, 3=c...
    my @x = split( //, $results );
    my $i = 1;
    for my $fresult (@x) {
        $template->param( "f$i" => $fresult );
        ++$i;
    }

    output_html_with_http_headers $cgi, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
