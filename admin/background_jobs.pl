#! /usr/bin/perl

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
use JSON qw( decode_json );
use Try::Tiny;

use C4::Context;
use C4::Auth;
use C4::Output;

use Koha::BackgroundJobs;
use Koha::Virtualshelves;

my $input             = new CGI;
my $op                = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/background_jobs.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'manage_background_jobs' }, # Maybe the "view" view should be accessible for the user who create this job.
                                                                       # But in that case what could the permission to check here? tools => '*' ?
        debug           => 1,
    }
);

my $dbh = C4::Context->dbh;

if ( $op eq 'view' ) {
    my $id = $input->param('id');
    if ( my $job = Koha::BackgroundJobs->find($id) ) {
        $template->param(
            job       => $job,
        );
        $template->param( lists => scalar Koha::Virtualshelves->search([{ category => 1, owner => $loggedinuser }, { category => 2 }]) )
            if $job->type eq 'batch_biblio_record_modification';
    } else {
        $op = 'list';
    }
}

if ( $op eq 'cancel' ) {
    my $id = $input->param('id');
    if ( my $job = Koha::BackgroundJobs->find($id) ) { # FIXME Make sure logged in user can cancel this job
        $job->cancel;
    }
    $op = 'list';
}


if ( $op eq 'list' ) {
    my $jobs = Koha::BackgroundJobs->search({}, { order_by => { -desc => 'enqueued_on' }});
    my @pending_jobs;
    try {
        my $conn = Koha::BackgroundJob->connect;
        my $job_type = 'batch_biblio_record_modification';
        $conn->subscribe({ destination => $job_type, ack => 'client' });
        my @frames;
        while (my $frame = $conn->receive_frame({timeout => 1})) {
            last unless $frame;
            my $body = $frame->body;
            my $args = decode_json($body);
            push @pending_jobs, $args->{job_id};
            push @frames, $frame;
        }
        $conn->nack( { frame => $_ } ) for @frames;
        $conn->disconnect;
    } catch {
        push @messages, {
            type => 'error',
            code => 'cannot_retrieve_jobs',
            error => $_,
        };
    };

    $template->param( jobs => $jobs, pending_jobs => \@pending_jobs, );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
