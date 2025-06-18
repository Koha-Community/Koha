#!/usr/bin/perl

# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
#
# This file is part of Koha.
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
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::BiblioFrameworks;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "recalls/recalls_old_queue.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { recalls => "manage_recalls" },
        debug         => 1,
    }
);

my $recalls = Koha::Recalls->search( { completed => 1 } );
$template->param(
    recalls     => $recalls,
    viewing_old => 1
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find('FA');

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
