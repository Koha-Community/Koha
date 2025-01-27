#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2015  Viktor Sarge
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
use CGI;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::AdditionalContents;

my $input = CGI->new;
my $dbh   = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-news-rss.tt",
        type            => "opac",
        query           => $input,
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

# Get the news to display
# use cookie setting for language, bug default to syspref if it's not set
my ( $theme, $news_lang, $availablethemes ) =
    C4::Templates::themelanguage( C4::Context->config('opachtdocs'), 'opac-main.tt', 'opac', $input );

my $branchcode = $input->param('branchcode');

my $koha_news = Koha::AdditionalContents->search_for_display(
    {
        category   => 'news',
        location   => [ 'opac_only', 'staff_and_opac' ],
        lang       => $news_lang,
        library_id => $branchcode,
    }
);

$template->param( koha_news => $koha_news );

output_html_with_http_headers $input, $cookie, $template->output;
