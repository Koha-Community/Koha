#!/usr/bin/perl
#
# This code  (originally from circulation.pl) has been modified by:
#   Trendsetters,
#   dan, and
#   Christina Lee.
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

use C4::Auth   qw( in_iprange get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

my $query = CGI->new;
unless ( in_iprange( C4::Context->preference('SelfCheckAllowByIPRanges') ) ) {
    print $query->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "sco/help.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

if ( C4::Context->preference('SelfCheckoutByLogin') ) {
    $template->param( SelfCheckoutByLogin => 1 );
}
my $selfchecktimeout = 120;
if ( C4::Context->preference('SelfCheckTimeout') ) {
    $selfchecktimeout = C4::Context->preference('SelfCheckTimeout');
}

$template->param( SelfCheckTimeout => $selfchecktimeout );

$template->param(
    SCOUserJS  => C4::Context->preference('SCOUserJS'),
    SCOUserCSS => C4::Context->preference('SCOUserCSS'),
);

output_html_with_http_headers $query, $cookie, $template->output;

