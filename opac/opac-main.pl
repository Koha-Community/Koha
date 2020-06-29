#!/usr/bin/perl

# This file is part of Koha.
#
# Parts Copyright (C) 2013  Mark Tompsett
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
use C4::NewsChannels;    # GetNewsToDisplay
use C4::Languages qw(getTranslatedLanguages accept_language);
use Koha::Quotes;
use C4::Members;
use C4::Overdues;
use Koha::Checkouts;
use Koha::Holds;
use Koha::News;

my $input = CGI->new;
my $dbh   = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-main.tt",
        type            => "opac",
        query           => $input,
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $casAuthentication = C4::Context->preference('casAuthentication');
$template->param(
    casAuthentication   => $casAuthentication,
);

my $homebranch;
if (C4::Context->userenv) {
    $homebranch = C4::Context->userenv->{'branch'};
}
if (defined $input->param('branch') and length $input->param('branch')) {
    $homebranch = $input->param('branch');
}
elsif (C4::Context->userenv and defined $input->param('branch') and length $input->param('branch') == 0 ){
   $homebranch = "";
}

my $news_id = $input->param('news_id');
my @all_koha_news;

if (defined $news_id){
    @all_koha_news = Koha::News->search({ idnew => $news_id, lang => { '!=', 'koha' } }); # get news that is not staff-only news
    if( @all_koha_news ) { # we only expect one btw
        $template->param( news_item => $all_koha_news[0] );
    } else {
        $template->param( single_news_error => 1 );
    }
} else {
    @all_koha_news   = &GetNewsToDisplay( $template->lang, $homebranch);
}

# For dashboard
my $patron = Koha::Patrons->find( $borrowernumber );

if ( $patron ) {
    my $checkouts = Koha::Checkouts->search({ borrowernumber => $borrowernumber })->count;
    my ( $overdues_count, $overdues ) = checkoverdues($borrowernumber);
    my $holds_pending = Koha::Holds->search({ borrowernumber => $borrowernumber, found => undef })->count;
    my $holds_waiting = Koha::Holds->search({ borrowernumber => $borrowernumber })->waiting->count;

    my $total = $patron->account->balance;

    if  ( $checkouts > 0 || $overdues_count > 0 || $holds_pending > 0 || $holds_waiting > 0 || $total > 0 ) {
        $template->param(
            dashboard_info => 1,
            checkouts           => $checkouts,
            overdues            => $overdues_count,
            holds_pending       => $holds_pending,
            holds_waiting       => $holds_waiting,
            total_owing         => $total,
        );
    }
}

$template->param(
    koha_news           => @all_koha_news,
    branchcode          => $homebranch,
    daily_quote         => Koha::Quotes->get_daily_quote(),
);

output_html_with_http_headers $input, $cookie, $template->output;
