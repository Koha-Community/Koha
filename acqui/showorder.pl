#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use CGI;

use C4::Auth;
use C4::Output;

use Koha::Acquisition::Orders;
use Koha::Patrons;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
    template_name   => "acqui/showorder.tt",
    query           => $cgi,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => { acquisition => '*' },
});

my $ordernumber = $cgi->param('ordernumber');
my $order = Koha::Acquisition::Orders->find($ordernumber);
my $creator = Koha::Patrons->find($order->created_by);

$template->param(
    order => $order,
    creator => $creator,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
