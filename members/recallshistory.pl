#!/usr/bin/perl

# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
#
# This file is part of Koha.

# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/recallshistory.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { recalls => 1 },
        debug         => 1,
    }
);

my $borrowernumber = $input->param('borrowernumber');
my $recalls = Koha::Recalls->search( { patron_id => $borrowernumber }, { order_by => { '-desc' => 'created_date' } } );
my $patron  = Koha::Patrons->find($borrowernumber);

$template->param(
    patron          => $patron,
    recalls         => $recalls,
    recallsview     => 1,
    specific_patron => 1,
);

output_html_with_http_headers $input, $cookie, $template->output;
