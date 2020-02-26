#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2019 Aleisha Amohia <aleisha@catalyst.net.nz>
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
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Members;
use C4::Letters;
use Koha::ProblemReport;
use Koha::DateUtils;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Util::Navigation;

my $input = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reportproblem.tt",
        type            => "opac",
        query           => $input,
        authnotrequired => 0,
    }
);

if ( !C4::Context->preference('OPACReportProblem') ){
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
}

my $problempage = C4::Context->preference('OPACBaseURL') . Koha::Util::Navigation::local_referer($input );

my $member = Koha::Patrons->find($borrowernumber);
my $username = $member->userid;
my $branchcode = $member->branchcode;
my $library = Koha::Libraries->find($branchcode);
my $recipients = 2;

if (
    ( !defined($library->branchreplyto) || $library->branchreplyto eq '' ) &&
    ( C4::Context->preference('ReplytoDefault') eq '' ) &&
    ( !defined($library->branchemail) || $library->branchemail eq '' )
    ) {
    $template->param( nolibemail => 1 );
    $recipients--;
}

my $koha_admin = C4::Context->preference('KohaAdminEmailAddress');
if ( $koha_admin eq '' ) {
    $template->param( noadminemail => 1 );
    $recipients--;
}

$template->param(
    username => $username,
    probpage => $problempage,
);

my $op = $input->param('op') || '';
if ( $op eq 'addreport' ) {

    if ( $recipients == 0 ){
        print $input->redirect("/cgi-bin/koha/opac-reportproblem?norecipients=1.pl");
        exit;
    }

    my $subject = $input->param('subject');
    my $message = $input->param('message');
    my $place = $input->param('place');
    my $recipient = $input->param('recipient') || 'library';
    my $problem = Koha::ProblemReport->new(
        {
            title          => $subject,
            content        => $message,
            borrowernumber => $borrowernumber,
            branchcode     => $branchcode,
            username       => $username,
            problempage    => $place,
            recipient      => $recipient,
        }
    )->store;
    $template->param(
        recipient => $recipient,
        successfuladd => 1,
        probpage => $place,
    );

    # send notice to library
    my $letter = C4::Letters::GetPreparedLetter(
        module => 'members',
        letter_code => 'PROBLEM_REPORT',
        branchcode => $problem->branchcode,
        tables => {
            'problem_reports', $problem->reportid
        }
    );

    my $from_address = C4::Context->preference('KohaAdminEmailAddress');
    my $transport = 'email';

    if ( $recipient eq 'admin' ) {
        C4::Letters::EnqueueLetter({
            letter                 => $letter,
            borrowernumber         => $borrowernumber,
            message_transport_type => $transport,
            to_address             => $koha_admin,
            from_address           => $from_address,
        });
    } else {
        my  $to_address = $library->branchreplyto ||
            C4::Context->preference('ReplytoDefault') ||
            $library->branchemail;
        C4::Letters::EnqueueLetter({
            letter                 => $letter,
            borrowernumber         => $borrowernumber,
            message_transport_type => $transport,
            to_address             => $to_address,
            from_address           => $from_address,
        });
    }
}

output_html_with_http_headers $input, $cookie, $template->output;
