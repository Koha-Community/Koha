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

# The "view" view should be accessible for the user who create this job.
my $flags_required = $op ne 'view' ? { parameters => 'manage_background_jobs' } : undef;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/background_jobs.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => $flags_required,
        debug           => 1,
    }
);

if ( $op eq 'view' ) {
    my $id = $input->param('id');
    if ( my $job = Koha::BackgroundJobs->find($id) ) {
        if ( $job->borrowernumber ne $loggedinuser
            && !Koha::Patrons->find($loggedinuser)->has_permission( { parameters => 'manage_background_jobs' } ) )
        {
            push @messages, { code => 'cannot_view_job' };
        }
        else {
            $template->param( job => $job, );
            $template->param(
                lists => scalar Koha::Virtualshelves->search(
                    [
                        { category => 1, owner => $loggedinuser },
                        { category => 2 }
                    ]
                )
            ) if $job->type eq 'batch_biblio_record_modification';
        }
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
    $template->param( jobs => $jobs );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
