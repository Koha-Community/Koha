#!/usr/bin/perl

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

use strict;
use warnings;
use C4::Auth;
use CGI;
use C4::Context;

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

sub plugin_parameters {
}

sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
    my $res="
    <script type='text/javascript'>
        function Focus$field_number() {
            return 1;
        }

        function Blur$field_number() {
                return 1;
        }

        function Clic$field_number() {
                var code = document.getElementById('$field_number');
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

    return ($field_number,$res);
}

my $BASE_CALLNUMBER_RE = qr/^(\w+) (\w+)$/;
sub plugin {
    my ($input) = @_;
    my $code = $input->param('code');

    my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "cataloguing/value_builder/ajax.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {editcatalogue => '*'},
        debug           => 1,
    });

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
}

1;
