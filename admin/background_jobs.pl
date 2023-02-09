#!/usr/bin/perl

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

use C4::Context;
use Koha::DateUtils qw( dt_from_string );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::BackgroundJobs;
use Koha::Virtualshelves;

my $input             = CGI->new;
my $op                = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/background_jobs.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $can_manage_background_jobs =
  $logged_in_user->has_permission( { parameters => 'manage_background_jobs' } );

if ( $op eq 'view' ) {
    my $id = $input->param('id');
    if ( my $job = Koha::BackgroundJobs->find($id) ) {
        if ( $job->borrowernumber ne $loggedinuser
            && !$can_manage_background_jobs )
        {
            push @messages, { code => 'cannot_view_job' };
        }
        else {
            $template->param( job => $job, );
            if ( $job->status ne 'new' ) {
                my $report = $job->additional_report() || {};
                $template->param( %$report );
            }
        }
    } else {
        $op = 'list';
    }
}

if ( $op eq 'cancel' ) {
    my $id = $input->param('id');
    my $job = Koha::BackgroundJobs->find($id);
    if (   $can_manage_background_jobs
        || $job->borrowernumber eq $logged_in_user->borrowernumber )
    {
        $job->cancel;
    }
    else {
        push @messages, { code => 'cannot_cancel_job' };
    }
    $op = 'list';
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
