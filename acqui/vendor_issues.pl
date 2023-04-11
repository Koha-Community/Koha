#!/usr/bin/perl

# Copyright 2023 Koha Development Team
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
use Try::Tiny;
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Acquisition::Booksellers;

my $input        = CGI->new;
my $booksellerid = $input->param('booksellerid');
my $issue_id     = $input->param('issue_id');
my $op           = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "acqui/vendor_issues.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { acquisition => 'issues_manage' },
    }
);

my $issue;
if ( $issue_id ) {
    $issue = Koha::Acquisition::Bookseller::Issues->find($issue_id);
    $booksellerid = $issue->vendor_id;
}
my $vendor = Koha::Acquisition::Booksellers->find($booksellerid);

if ( $op eq 'add_form' || $op eq 'show' ) {
    $template->param( issue => $issue );
} elsif ( $op eq 'add_validate' ) {
    my $type       = $input->param('type');
    my $started_on = $input->param('started_on');
    my $ended_on   = $input->param('ended_on');
    my $notes      = $input->param('notes');

    if ($issue_id) {
        try {
            $issue->set(
                {
                    type       => $type,
                    started_on => $started_on,
                    ended_on   => $ended_on,
                    notes      => $notes
                }
            )->store;
            push @messages, { type => 'message', code => 'success_on_update' };
        } catch {
            push @messages, { type => 'error', code => 'error_on_update' };
        };
    } else {
        try {
            Koha::Acquisition::Bookseller::Issue->new(
                {
                    vendor_id  => $booksellerid,
                    type       => $type,
                    started_on => $started_on,
                    ended_on   => $ended_on,
                    notes      => $notes,
                }
            )->store;
            push @messages, { type => 'message', code => 'success_on_insert' };
        } catch {
            push @messages, { type => 'error', code => 'error_on_insert' };
        };
    }
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    $template->param( issue => $issue );
} elsif ( $op eq 'delete_confirmed' ) {
    try {
        $issue->delete;
        push @messages, { type => 'message', code => 'success_on_delete' };
    } catch {
        push @messages, { type => 'error', code => 'error_on_delete' };
    };
    $op = 'list';
}

if ( $op eq 'list' ) {
    $template->param( issues_count => $vendor->issues->search->count );
}

$template->param(
    messages     => \@messages,
    op           => $op,
    vendor       => $vendor,
    booksellerid => $vendor->id,    # Used by vendor-menu.inc
);

output_html_with_http_headers $input, $cookie, $template->output;
