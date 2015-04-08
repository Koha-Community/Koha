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


use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;

my $query = new CGI;
my $admin = C4::Context->preference('KohaAdminEmailAddress');
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "errors/500.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);
$template->param( admin => $admin );
output_with_http_headers $query, $cookie, $template->output, 'html', '500 Internal Server Error';
