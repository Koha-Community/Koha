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
use C4::Context;
use C4::Auth;
use C4::Output;

use Koha::BackgroundJob;
use Koha::BackgroundJobs;

my $input             = new CGI;
my $op                = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/background_jobs.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'manage_background_jobs' }, # TODO Add this new permission, so far only works for superlibrarians
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
    } else {
        $op = 'list';
    }

}

if ( $op eq 'list' ) {
    my $jobs = Koha::BackgroundJobs->search({}, { order_by => { -desc => 'enqueued_on' }});
    $template->param( jobs => $jobs, );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
