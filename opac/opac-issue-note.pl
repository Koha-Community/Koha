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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Koha;
use C4::Context;
use C4::Scrubber;
use C4::Output;
use C4::Auth;
use C4::Biblio;
use C4::Letters;
use Koha::Checkouts;
use Koha::DateUtils;
use Koha::Patrons;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-issue-note.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $patron = Koha::Patrons->find( $borrowernumber );
$template->param(
    firstname      => $patron->firstname,
    surname        => $patron->surname,
    borrowernumber => $borrowernumber,
);

my $issue_id = $query->param('issue_id');
my $issue = Koha::Checkouts->find( $issue_id );
my $itemnumber = $issue->itemnumber;
my $biblio = $issue->item->biblio;
$template->param(
    issue_id   => $issue_id,
    title      => $biblio->title,
    author     => $biblio->author,
    note       => $issue->note,
    itemnumber => $issue->itemnumber,
);

my $action = $query->param('action') || "";
if ( $action eq 'issuenote' && C4::Context->preference('AllowCheckoutNotes') ) {
    my $note = $query->param('note');
    my $scrubber = C4::Scrubber->new();
    my $clean_note = $scrubber->scrub($note);
    if ( $issue->set({ notedate => dt_from_string(), note => $clean_note, noteseen => 0 })->store ) {
        if ($clean_note) { # only send email if note not empty
            my $branch = Koha::Libraries->find( $issue->branchcode );
            my $letter = C4::Letters::GetPreparedLetter (
                module => 'circulation',
                letter_code => 'CHECKOUT_NOTE',
                branchcode => $branch,
                tables => {
                    'biblio' => $biblio->biblionumber,
                    'borrowers' => $borrowernumber,
                },
            );

            my $to_address = $branch->branchemail || $branch->branchreplyto || C4::Context->ReplytoDefault || C4::Context->preference('KohaAdminEmailAddress');
            my $from_address = $patron->email || $patron->emailpro || $patron->B_email;

            C4::Letters::EnqueueLetter({
                letter => $letter,
                message_transport_type => 'email',
                borrowernumber => $patron->borrowernumber,
                to_address => $to_address,
                from_address => $from_address,
            });
        }
    }
    print $query->redirect("/cgi-bin/koha/opac-user.pl");
}

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
