#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright 2012 CatalystIT Ltd
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
use C4::Context;
use C4::Output qw( output_html_with_http_headers );

=head1 DESCRIPTION

Is used for callnumber computation.

User must supply a letter prefix (unspecified length) followed by an empty space followed by a "number".
"Number" is 4 character long, and is either a number sequence which is 01 padded.
If input does not conform with this format any processing is omitted.

Some examples of legal values that trigger auto allocation:

AAA 0  - returns first unused number AAA 0xxx starting with AAA 0001
BBB 12 - returns first unused number BBB 12xx starting with BBB 1201
CCC QW - returns first unused number CCC QWxx starting with CCC QW01

=cut

my $builder = sub {
    my ( $params ) = @_;
    my $res="
    <script>
        function Click$params->{id}(ev) {
                ev.preventDefault();
                var code = document.getElementById(ev.data.id);
                var url = '../cataloguing/plugin_launcher.pl?plugin_name=callnumber-KU.pl&code=' + code.value;
                var req = \$.get(url);
                req.done(function(resp){
                    code.value = resp;
                    return 1;
                });
            return 1;
        }
    </script>
    ";
    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $code = $input->param('code');

    my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "cataloguing/value_builder/ajax.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => {editcatalogue => '*'},
    });

    my $BASE_CALLNUMBER_RE = qr/^(\w+) (\w+)$/;
    my $ret;
    my ($alpha, $num) = ($code =~ $BASE_CALLNUMBER_RE);
    if (defined $num) { # otherwise no point
        my ($num_alpha, $num_num) = ($num =~ m/^(\D+)?(\d+)?$/);
        $num_alpha ||= '';
        my $pad_len = 4 - length($num);

        if ($pad_len > 0) {
            my $num_padded = $num_num;
            $num_padded .= "0" x ($pad_len - 1) if $pad_len > 1;
            $num_padded .= "1";
            my $padded = "$alpha $num_alpha" . $num_padded;

            my $dbh = C4::Context->dbh;
            if ( my $first = $dbh->selectrow_array("SELECT itemcallnumber
                                                    FROM items
                                                    WHERE itemcallnumber = ?", undef, $padded) ) {
                my $icn = $dbh->selectcol_arrayref("SELECT DISTINCT itemcallnumber
                                                    FROM items
                                                    WHERE itemcallnumber LIKE ?
                                                      AND itemcallnumber >   ?
                                                    ORDER BY itemcallnumber", undef, "$alpha $num_alpha%", $first);
                my $next = $num_padded + 1;
                my $len = length($num_padded);
                foreach (@$icn) {
                    my ($num1) = ( m/(\d+)$/o );
                    if ($num1 > $next) { # a hole in numbering found, stop
                        last;
                    }
                    $next++;
                }
                $ret = "$alpha $num_alpha" . sprintf("%0${len}d", $next) if length($next) <= $len; # no overflow
            }
            else {
                $ret = $padded;
            }
        }
    }

    $template->param(
        return => $ret || $code
    );
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
