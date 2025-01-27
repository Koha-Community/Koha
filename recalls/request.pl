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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Search;
use Koha::Recalls;
use Koha::Biblios;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "recalls/request.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { recalls => "manage_recalls" },
        debug         => 1,
    }
);

my $op           = $input->param('op') || 'list';
my @recall_ids   = $input->multi_param('recall_ids');
my $biblionumber = $input->param('biblionumber');
my $recalls      = Koha::Recalls->search( { biblio_id => $biblionumber, completed => 0 } );
my $biblio       = Koha::Biblios->find($biblionumber);

if ( $op eq 'cud-cancel_multiple_recalls' ) {
    foreach my $id (@recall_ids) {
        Koha::Recalls->find($id)->set_cancelled;
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    $recalls = Koha::Recalls->search( { biblio_id => $biblionumber, completed => 0 } );
    $biblio  = Koha::Biblios->find($biblionumber);
}

$template->param(
    recalls     => $recalls,
    recallsview => 1,
    biblio      => $biblio,
    checkboxes  => 1,
    C4::Search::enabled_staff_search_views,
);

output_html_with_http_headers $input, $cookie, $template->output;
