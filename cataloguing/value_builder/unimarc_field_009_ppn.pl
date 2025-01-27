#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

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
use LWP::Simple qw();
use LWP::UserAgent;
use JSON;
use C4::Auth   qw ( get_template_and_user );
use C4::Output qw ( output_html_with_http_headers );

my $res;
my $builder = sub {
    my ($params) = @_;
    my $res = qq|
        <script>
            jQuery(document).ready(function () {
                const input = document.getElementById('$params->{id}');
                const isbn_input = jQuery('input[id^="tag_010_subfield_a_"]');
                const issn_input = jQuery('input[id^="tag_011_subfield_a_"]');
                const ean_input = jQuery('input[id^="tag_073_subfield_a_"]');

                isbn_input.on('change', function () {
                    update_ppn('isbn', this.value);
                });
                issn_input.on('change', function () {
                    update_ppn('issn', this.value);
                });
                ean_input.on('change', function () {
                    update_ppn('ean', this.value);
                });

                jQuery(input).on('focus', function () {
                    const isbn = isbn_input.val().trim();
                    const issn = issn_input.val().trim();
                    const ean = ean_input.val().trim();
                    if (isbn !== '') {
                        update_ppn('isbn', isbn);
                    } else if (issn !== '') {
                        update_ppn('issn', issn);
                    } else if (ean !== '') {
                        update_ppn('ean', ean);
                    }
                });

                function update_ppn(search_type, search_text) {
                    if (input.value.trim() === '') {
                        get_ppn(search_type, search_text).then(function (ppn) {
                            input.value = ppn;
                        });
                    }
                }

                function get_ppn(search_type, search_text) {
                    const url = '/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_009_ppn.pl&' + search_type + '=' + encodeURIComponent(search_text);

                    return jQuery.get(url);
                }
            });
        </script>
    |;
    return $res;
};

my $launcher = sub {
    my ($params) = @_;
    my $input    = $params->{cgi};
    my $isbn     = $input->param('isbn');
    my $issn     = $input->param('issn');
    my $ean      = $input->param('ean');

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "cataloguing/value_builder/ajax.tt",
            query         => $input,
            type          => "intranet",
            flagsrequired => { editcatalogue => '*' },
        }
    );

    my $url;
    if ($isbn) {
        $url = "https://www.sudoc.fr/services/isbn2ppn/$isbn&format=text/json";
    } elsif ($issn) {
        $url = "https://www.sudoc.fr/services/issn2ppn/$issn&format=text/json";
    } elsif ($ean) {
        $url = "https://www.sudoc.fr/services/ean2ppn/$ean&format=text/json";
    }

    if ($url) {
        my $json = LWP::Simple::get($url);
        if ( defined $json ) {
            my $response = JSON->new->utf8->decode($json);
            my $result   = $response->{sudoc}->{query}->{result};
            my $ppn      = ref $result eq 'ARRAY' ? $result->[0]->{ppn} : $result->{ppn};
            $template->param( return => $ppn );
        }
    }

    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
