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

my $builder = sub {
    my $params = shift;
    my $id     = $params->{id};

    return qq|
<script>

function Click$id(event) {
    var fieldvalue=\$('#'+event.data.id).val();
    window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_181c.pl&index=\"+event.data.id+\"&result=\"+fieldvalue,\"tag_editor\",'width=700,height=700,toolbar=false,scrollbars=yes');
    return false; /* prevents scrolling */
}
</script>|;
};

my $launcher = sub {
    my $params = shift;
    my $cgi    = $params->{cgi};
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/unimarc_field_181c.tt",
            query         => $cgi,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );
    my $results = scalar $cgi->param('result');
    my $input_a = substr $results, 0, 3;

    $template->param(
        index  => scalar $cgi->param('index'),
        result => $results,
        f1     => $input_a,
    );

    output_html_with_http_headers $cgi, $cookie, $template->output;
};

# Return the hashref with the builder and launcher to FrameworkPlugin object.
# NOTE: If you do not need a popup but only use e.g. Focus, Blur etc. for a
# particular plugin, you only need to define and return the builder.
return { builder => $builder, launcher => $launcher };
