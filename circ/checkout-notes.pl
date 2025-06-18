#!/usr/bin/perl

# Copyright 2016 Aleisha Amohia <aleisha@catalyst.net.nz>
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use Koha::Checkouts;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/checkout-notes.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { circulate => "manage_checkout_notes" },
    }
);

my $op = $query->param("op") || 'none';

my @issue_ids = $query->multi_param('issue_ids');

if ( $op eq 'cud-seen' ) {
    foreach my $issue_id (@issue_ids) {
        my $issue = Koha::Checkouts->find($issue_id);
        $issue->set( { noteseen => 1 } )->store;
    }
} elsif ( $op eq 'cud-notseen' ) {
    foreach my $issue_id (@issue_ids) {
        my $issue = Koha::Checkouts->find($issue_id);
        $issue->set( { noteseen => 0 } )->store;
    }
}

my $notes = Koha::Checkouts->search(
    { 'me.note' => { '!=', undef } },
    { prefetch  => [ 'patron', { item => 'biblionumber' } ] }
);
$template->param(
    selected_count => scalar(@issue_ids),
    op             => $op,
    notes          => $notes,
);

output_html_with_http_headers $query, $cookie, $template->output;
