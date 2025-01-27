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
use CGI       qw ( -utf8 );
use Try::Tiny qw( catch try );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Letters;
use Koha::ProblemReport;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Util::Navigation;
use URI::Escape qw( uri_unescape );
use Encode;

my $input = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reportproblem.tt",
        type            => "opac",
        query           => $input,
        authnotrequired => 0,
    }
);

if (   !C4::Context->preference('OPACReportProblem')
    || !C4::Context->preference('KohaAdminEmailAddress') )
{
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
}

my $referer = Koha::Util::Navigation::local_referer($input);
$referer = Encode::decode_utf8 uri_unescape $referer,

    my $patron = Koha::Patrons->find($borrowernumber);
my $library  = $patron->library;
my $username = $patron->userid;
my @messages;

$template->param(
    username    => $username,
    problempage => $referer,
    library     => $library,
);

my $op = $input->param('op') || '';
if ( $op eq 'cud-addreport' ) {

    my $subject     = $input->param('subject');
    my $message     = $input->param('message');
    my $problempage = $input->param('problempage');
    $problempage = Encode::decode_utf8 uri_unescape $problempage;
    my $recipient = $input->param('recipient') || 'admin';

    try {
        my $schema = Koha::Database->new->schema;
        $schema->txn_do(
            sub {
                my $problem = Koha::ProblemReport->new(
                    {
                        title          => $subject,
                        content        => $message,
                        borrowernumber => $borrowernumber,
                        branchcode     => $patron->branchcode,
                        username       => $username,
                        problempage    => $problempage,
                        recipient      => $recipient,
                    }
                )->store;

                # send notice to library
                my $letter = C4::Letters::GetPreparedLetter(
                    module      => 'members',
                    letter_code => 'PROBLEM_REPORT',
                    branchcode  => $problem->branchcode,
                    tables      => { 'problem_reports', $problem->reportid }
                );

                my $transport     = 'email';
                my $reply_address = $patron->email || $patron->emailpro || $patron->B_email;

                if (    $recipient eq 'library'
                    and defined( $library->inbound_email_address )
                    and $library->inbound_email_address ne C4::Context->preference('KohaAdminEmailAddress') )
                {
                    # the problem report is intended for a librarian and will be received at a library email address
                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $letter,
                            borrowernumber         => $borrowernumber,
                            message_transport_type => $transport,
                            to_address             => $library->inbound_email_address,
                            reply_address          => $reply_address,
                        }
                    );
                } else {
                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $letter,
                            borrowernumber         => $borrowernumber,
                            message_transport_type => $transport,
                            to_address             => C4::Context->preference('KohaAdminEmailAddress'),
                            reply_address          => $reply_address,
                        }
                    );
                }

                push @messages, {
                    type => 'info',
                    code => 'success_on_send',
                };

                $template->param(
                    recipient => $recipient,
                );
            }
        );
    } catch {
        warn "Something wrong happened when sending the report problem: $_";
        push @messages, {
            type => 'error',
            code => 'error_on_send',
        };
    }
}

$template->param( messages => \@messages );

output_html_with_http_headers $input, $cookie, $template->output;
