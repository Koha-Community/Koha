#!/usr/bin/perl

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

=head1 SYNOPSIS

This plugin is used to fill 225$a with a value already existing in
biblioitems.collectiontitle

=cut

use Modern::Perl;

use C4::Auth qw( get_template_and_user );
use CGI qw( -utf8 );
use C4::Context;

use C4::Output qw( output_html_with_http_headers );

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number ) = @_;
    my $function_name = $field_number;
    my $res           = "
    <script>
        function Clic$function_name(event) {
            event.preventDefault();
            window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_225a_bis.pl&index=\"+event.data.id,\"unimarc225a\",'width=500,height=400,toolbar=false,scrollbars=no');
        }
    </script>
";

    return ( $function_name, $res );
}

sub plugin {
    my ($input) = @_;
    my $index   = $input->param('index');

    my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "cataloguing/value_builder/unimarc_field_225a_bis.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { editcatalogue => '*' },
    });

    $template->param(index => $index);

    output_html_with_http_headers $input, $cookie, $template->output;
}
