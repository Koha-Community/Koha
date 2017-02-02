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
use C4::Members;
use C4::Output;
use C4::Auth;
use C4::Biblio;
use C4::Letters;
use Koha::Checkouts;
use Koha::DateUtils;

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

my $member = C4::Members::GetMember( borrowernumber => $borrowernumber );
$template->param(
    firstname      => $member->{'firstname'},
    surname        => $member->{'surname'},
    borrowernumber => $borrowernumber,
);

my $issue_id = $query->param('issue_id');
my $issue = Koha::Checkouts->find( $issue_id );
my $itemnumber = $issue->itemnumber;
my $biblio = GetBiblioFromItemNumber($itemnumber);
$template->param(
    issue_id   => $issue_id,
    title      => $biblio->{'title'},
    author     => $biblio->{'author'},
    note       => $issue->note,
    itemnumber => $issue->itemnumber,
);

my $action = $query->param('action') || "";
if ( $action eq 'issuenote' && C4::Context->preference('AllowCheckoutNotes') ) {
    my $note = $query->param('note');
    my $scrubber = C4::Scrubber->new();
    my $clean_note = $scrubber->scrub($note);
    if ( $issue->set({ notedate => dt_from_string(), note => $clean_note })->store ) {
        if ($clean_note) { # only send email if note not empty
            my $branch = Koha::Libraries->find( $issue->branchcode );
            my $letter = C4::Letters::GetPreparedLetter (
                module => 'circulation',
                letter_code => 'PATRON_NOTE',
                branchcode => $branch,
                tables => {
                    'biblio' => $biblio->{biblionumber},
                    'borrowers' => $member->{borrowernumber},
                },
            );
            C4::Message->enqueue($letter, $member, 'email');
        }
    }
    print $query->redirect("/cgi-bin/koha/opac-user.pl");
}

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
