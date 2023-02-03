#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2012 BibLibre SARL
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
use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::AuthorisedValues;

=head1 DESCRIPTION

This plugin is based on authorised values from INVENTORY.
It is used for stocknumber computation.

If no prefix is submitted, or the prefix does contain only
numbers, it returns the inserted code (= keep the field unchanged).

If a prefix is submitted, we look for the highest stocknumber
with this prefix and return it incremented.

In this case, a stocknumber has this form (e.g. "PREFIX 0009678570"):
PREFIX containing letters, a space separator and 10 digits with leading
0s if needed.

=cut

my $builder = sub {
    my ( $params ) = @_;
    my $res = qq{
    <script>
        function Click$params->{id}(ev) {
                ev.preventDefault();
                var code = document.getElementById(ev.data.id);
                \$.ajax({
                    url: '/cgi-bin/koha/cataloguing/plugin_launcher.pl',
                    type: 'POST',
                    data: {
                        'plugin_name': 'stocknumberAV.pl',
                        'code'    : code.value,
                    },
                    success: function(data){
                        var field = document.getElementById(ev.data.id);
                        field.value = data;
                        return 1;
                    }
                });
        }
    </script>
    };

    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $code = $input->param('code');

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/ajax.tt",
            query           => $input,
            type            => "intranet",
            flagsrequired   => { editcatalogue => '*' },
        }
    );

    # If a prefix is submited, we look for the highest stocknumber with this prefix, and return it incremented
    $code =~ s/ *$//g;
    if ( $code =~ m/^[a-zA-Z]+$/ ) {
        my $av = Koha::AuthorisedValues->find({
            'category' => 'INVENTORY',
            'authorised_value' => $code
        });
        if ( $av ) {
            $av->lib($av->lib + 1);
            $av->store;
            $template->param( return => $code . ' ' . sprintf( '%010s', ( $av->lib ) ), );
        } else {
            $template->param( return => "There is no defined value for $code");
        }
        # The user entered a custom value, we don't touch it, this could be handled in js
    } else {
        $template->param( return => $code, );
    }

    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
