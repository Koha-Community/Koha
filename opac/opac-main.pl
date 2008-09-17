#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::VirtualShelves;
use C4::Branch;          # GetBranches
use C4::Members;         # GetMember
use C4::NewsChannels;    # get_opac_news
use C4::Acquisition;     # GetRecentAcqui

my $input = new CGI;
my $dbh   = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-main.tmpl",
        type            => "opac",
        query           => $input,
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $borrower = GetMember( $borrowernumber, 'borrowernumber' );
$template->param(
    textmessaging        => $borrower->{textmessaging},
);

# display news
# use cookie setting for language, bug default to syspref if it's not set
my $news_lang = $input->cookie('KohaOpacLanguage') || 'en';
my $all_koha_news   = &GetNewsToDisplay($news_lang);
my $koha_news_count = scalar @$all_koha_news;

$template->param(
    koha_news       => $all_koha_news,
    koha_news_count => $koha_news_count
);

output_html_with_http_headers $input, $cookie, $template->output;
