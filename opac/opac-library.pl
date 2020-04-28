#!/usr/bin/perl

# Copyright 2020 Athens County Public Libraries
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
use C4::Auth;
use C4::Output;
use Koha::Libraries;

my $query = CGI->new();

my $branchcode   = $query->param('branchcode');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-library.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

if( $branchcode ){
    my $library = Koha::Libraries->find( $branchcode );
    $template->param( library => $library );
}

my $libraries = Koha::Libraries->search( {}, { order_by => ['branchname'] }, );
$template->param(
    libraries => $libraries,
    branchcode => $branchcode,
);

output_html_with_http_headers $query, $cookie, $template->output;
