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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
use warnings;
use CGI;

use C4::Auth   qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);

my $query = new CGI;
my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => "sco/help.tt",
    query => $query,
     type => "opac",
    debug => 1,
    authnotrequired => 1,
      flagsrequired => {circulate => "circulate_remaining_permissions"},
});

if (C4::Context->preference('SelfCheckoutByLogin')) {
    $template->param(SelfCheckoutByLogin => 1);
}
my $selfchecktimeout = 120;
if (C4::Context->preference('SelfCheckTimeout')) {
   $selfchecktimeout = C4::Context->preference('SelfCheckTimeout');
}

$template->param(SelfCheckTimeout => $selfchecktimeout);

if (C4::Context->preference('SelfCheckHelpMessage')) {
    $template->param(SelfCheckHelpMessage => C4::Context->preference('SelfCheckHelpMessage'));
}

$template->param(
    SCOUserJS  => C4::Context->preference('SCOUserJS'),
    SCOUserCSS => C4::Context->preference('SCOUserCSS'),
);

output_html_with_http_headers $query, $cookie, $template->output;

