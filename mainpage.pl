#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright Paul Poulain 2002
# Parts Copyright Liblime 2007
# Copyright (C) 2013  Mark Tompsett
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
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use C4::Koha;
use C4::Tags qw( get_count_by_tag_status );
use Koha::AdditionalContents;
use Koha::Patron::Modifications;
use Koha::Patron::Discharge;
use Koha::Reviews;
use Koha::ArticleRequests;
use Koha::ProblemReports;
use Koha::Quotes;
use Koha::Suggestions;
use Koha::BackgroundJobs;
use Koha::CurbsidePickups;
use Koha::Tickets;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "intranet-main.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1, },
    }
);

my $logged_in_user = Koha::Patrons->find($loggedinuser);

my $homebranch;
if (C4::Context->userenv) {
    $homebranch = C4::Context->userenv->{'branch'};
}
my $koha_news = Koha::AdditionalContents->search_for_display(
    {
        category   => 'news',
        location   => [ 'staff_only', 'staff_and_opac' ],
        lang       => $template->lang,
        library_id => $homebranch
    }
);

$template->param(
    koha_news   => $koha_news,
    daily_quote => Koha::Quotes->get_daily_quote(),
);

my $branch =
  (      C4::Context->preference("IndependentBranchesPatronModifications")
      || C4::Context->preference("IndependentBranches") )
  && !$flags->{'superlibrarian'}
  ? C4::Context->userenv()->{'branch'}
  : undef;

my $pendingcomments    = Koha::Reviews->search_limited({ approved => 0 })->count;
my $pendingtags        = get_count_by_tag_status(0);

# Get current branch count and total viewable count, if they don't match then pass
# both to template

if( C4::Context->only_my_library ){
    my $local_pendingsuggestions_count = Koha::Suggestions->search({ status => "ASKED", branchcode => C4::Context->userenv()->{'branch'} })->count();
    $template->param( pendingsuggestions => $local_pendingsuggestions_count );
} else {
    my $pendingsuggestions = Koha::Suggestions->search({ status => "ASKED" });
    my $local_pendingsuggestions_count = $pendingsuggestions->search({ 'me.branchcode' => C4::Context->userenv()->{'branch'} })->count();
    my $pendingsuggestions_count = $pendingsuggestions->count();
    $template->param(
        all_pendingsuggestions => $pendingsuggestions_count != $local_pendingsuggestions_count ? $pendingsuggestions_count : 0,
        pendingsuggestions => $local_pendingsuggestions_count
    );
}

my $pending_borrower_modifications = Koha::Patron::Modifications->pending_count( $branch );
my $pending_discharge_requests = Koha::Patron::Discharge::count({ pending => 1 });
my $pending_article_requests = Koha::ArticleRequests->search_limited(
    {
        status => Koha::ArticleRequest::Status::Requested,
        $branch ? ( 'me.branchcode' => $branch ) : (),
    }
)->count;
my $pending_problem_reports = Koha::ProblemReports->search({ status => 'New' });

if ( C4::Context->preference('OpacCatalogConcerns') ) {
    my $pending_biblio_tickets = Koha::Tickets->search(
        {
            resolved_date => undef,
            biblio_id     => { '!=' => undef }
        }
    );
    $template->param(
        pending_biblio_tickets => $pending_biblio_tickets->count );
}

unless ( $logged_in_user->has_permission( { parameters => 'manage_background_jobs' } ) ) {
    my $already_ran_jobs = Koha::BackgroundJobs->search(
        { borrowernumber => $logged_in_user->borrowernumber } )->count ? 1 : 0;
    $template->param( already_ran_jobs => $already_ran_jobs );
}

if ( C4::Context->preference('CurbsidePickup') ) {
    $template->param(
        new_curbside_pickups => Koha::CurbsidePickups->search(
            {
                branchcode                => $homebranch,
            }
        )->filter_by_to_be_staged->filter_by_scheduled_today,
    );
}

$template->param(
    pendingcomments                => $pendingcomments,
    pendingtags                    => $pendingtags,
    pending_borrower_modifications => $pending_borrower_modifications,
    pending_discharge_requests     => $pending_discharge_requests,
    pending_article_requests       => $pending_article_requests,
    pending_problem_reports        => $pending_problem_reports
);

output_html_with_http_headers $query, $cookie, $template->output;
