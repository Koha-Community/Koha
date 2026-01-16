#!/usr/bin/perl

# Copyright 2025 BibLibre SARL
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
use CGI qw ( -utf8 );

use C4::Auth       qw( get_template_and_user );
use C4::Output     qw( output_html_with_http_headers );
use Business::ISBN qw( valid_isbn_checksum );

my $builder = sub {
    my $params = shift;
    my $id     = $params->{id};

    return qq|
<script>
function Change$id(event) {
    field = \$('#'+event.data.id);
    isbn = field.val();
    var url = '../cataloguing/plugin_launcher.pl?plugin_name=validate_isbn.pl&isbn=' + isbn;
    var req = \$.get(url);
    req.done(function(resp){
        field.addClass("checked_isbn");
        if ( resp == 1 ) field.removeClass("subfield_not_filled");
        else {
           field.addClass("subfield_not_filled");
           field.focus();
           alert("Invalid ISBN : " + isbn);
        }
    });
}
function Blur$id(event) {
    field = \$('#'+event.data.id);
    // when not yet checked (in existing record), trigger change event
    if ( !field.hasClass("checked_isbn") ) field.trigger("change");
}
</script>|;
};

my $launcher = sub {
    my $params = shift;
    my $cgi    = $params->{cgi};
    my $isbn   = $cgi->param('isbn');

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/ajax.tt",
            query         => $cgi,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );
    my $is_valid = $isbn eq q{} ? 1 : valid_isbn_checksum($isbn);
    $template->param( return => $is_valid );
    output_html_with_http_headers $cgi, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
