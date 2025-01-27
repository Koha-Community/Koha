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
#

use Modern::Perl;

use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use C4::Context;
use C4::RotatingCollections;

use CGI qw ( -utf8 );

my $query = CGI->new;

my $op       = $query->param('op') || q{};
my $colId    = $query->param('colId');
my $toBranch = $query->param('toBranch');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "rotating_collections/transferCollection.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { tools => 'rotating_collections' },
    }
);

## Transfer collection
my ( $success, $messages );
if ( $op eq 'cud-transfer' && $toBranch ) {
    ( $success, $messages ) = TransferCollection( $colId, $toBranch );

    if ($success) {
        $template->param(
            transferSuccess => 1,
            messages        => $messages
        );
    } else {
        $template->param(
            transferFailure => 1,
            messages        => $messages
        );
    }
}

## Get data about collection
my ( $colTitle, $colDesc, $colBranchcode );
( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection($colId);
$template->param(
    colId         => $colId,
    colTitle      => $colTitle,
    colDesc       => $colDesc,
    colBranchcode => $colBranchcode,
);

output_html_with_http_headers $query, $cookie, $template->output;
