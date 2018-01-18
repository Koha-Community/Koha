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
use C4::Koha qw( GetDailyQuote );
use C4::Members;
use C4::Overdues;
use Koha::Checkouts;
use Koha::Holds;

my $input = new CGI;
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

# display news
# use cookie setting for language, bug default to syspref if it's not set
my ($theme, $news_lang, $availablethemes) = C4::Templates::themelanguage(C4::Context->config('opachtdocs'),'opac-main.tt','opac',$input);

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
my $all_koha_news   = &GetNewsToDisplay($news_lang,$homebranch);
my $koha_news_count = scalar @$all_koha_news;

my $quote = GetDailyQuote();   # other options are to pass in an exact quote id or select a random quote each pass... see perldoc C4::Koha

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
    koha_news           => $all_koha_news,
    koha_news_count     => $koha_news_count,
    branchcode          => $homebranch,
    display_daily_quote => C4::Context->preference('QuoteOfTheDay'),
    daily_quote         => $quote,
);

# If GoogleIndicTransliteration system preference is On Set parameter to load Google's javascript in OPAC search screens
if (C4::Context->preference('GoogleIndicTransliteration')) {
        $template->param('GoogleIndicTransliteration' => 1);
}

output_html_with_http_headers $input, $cookie, $template->output;
