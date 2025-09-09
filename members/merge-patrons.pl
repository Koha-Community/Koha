#!/usr/bin/perl

# Copyright ByWater Solutions 2017
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
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use Koha::Patrons;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "members/merge-patrons.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { borrowers => 'merge_borrowers' },
    }
);

my $op = $cgi->param('op') || 'show';
my @ids    = $cgi->multi_param('id');

if ( $op eq 'show' ) {
    my $patrons = Koha::Patrons->search({ borrowernumber => { -in => \@ids } });
    $template->param( patrons => $patrons );
} elsif ( $op eq 'cud-merge' ) {
    my $keeper_id = $cgi->param('keeper');
    my $results;

    my $keeper = Koha::Patrons->find( $keeper_id );

    if ( $keeper ) {
        try {
            $results = $keeper->merge_with( \@ids );
            $template->param(
                keeper  => $keeper,
                results => $results
            );
        }
        catch {
            $template->param( error => $_ );
        }
    } else {
        $template->param( error => 'INVALID_KEEPER' );
    }
}

$template->param( op => $op );

output_html_with_http_headers $cgi, $cookie, $template->output;

1;
