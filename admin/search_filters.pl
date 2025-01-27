#!/usr/bin/perl

# Copyright 2022 ByWater Solutions
#
# This file is part of Koha
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
use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::SearchFilters;

use Try::Tiny qw( catch try);

my $cgi = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => 'admin/search_filters.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { parameters => 'manage_search_filters' },
    }
);

my $op = $cgi->param('op') || '';

if ( $op eq 'cud-del' ) {
    my $id = $cgi->param('id');
    my $sf = Koha::SearchFilters->find($id);
    $template->param( filter_not_found => 1 ) unless $sf;
    if ($sf) {
        try {
            $sf->delete();
            $template->param( filter_deleted => $sf->name );
        } catch {
            $template->param( error => $_ );
        };
    }
}

my $filters = Koha::SearchFilters->search();

$template->param(
    filters_count => $filters->count,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
