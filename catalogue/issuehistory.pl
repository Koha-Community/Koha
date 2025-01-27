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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use C4::Search  qw( enabled_staff_search_views );
use C4::Serials qw( CountSubscriptionFromBiblionumber );
use Koha::Checkouts;
use Koha::Old::Checkouts;

use Koha::Biblios;

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/issuehistory.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $biblionumber = $query->param('biblionumber');

my @checkouts = Koha::Checkouts->search(
    { biblionumber => $biblionumber },
    {
        join     => 'item',
        order_by => 'timestamp',
    }
)->as_list;
my @old_checkouts = Koha::Old::Checkouts->search(
    { biblionumber => $biblionumber },
    {
        join     => 'item',
        order_by => 'timestamp',
    }
)->as_list;

my $biblio = Koha::Biblios->find($biblionumber);

$template->param(
    checkouts        => [ @checkouts, @old_checkouts ],
    biblio           => $biblio,
    issuehistoryview => 1,
    C4::Search::enabled_staff_search_views,
    subscriptionsnumber => CountSubscriptionFromBiblionumber($biblionumber),
);

output_html_with_http_headers $query, $cookie, $template->output;
