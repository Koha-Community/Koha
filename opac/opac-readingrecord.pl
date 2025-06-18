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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::Biblio;
use C4::External::BakerTaylor qw( image_url link_url );
use MARC::Record;

use C4::Output qw( output_html_with_http_headers );
use Koha::Patrons;

use Koha::ItemTypes;

my $query = CGI->new;

# if opacreadinghistory is disabled, leave immediately
if ( !C4::Context->preference('opacreadinghistory') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-readingrecord.tt",
        query         => $query,
        type          => "opac",
    }
);

my $patron     = Koha::Patrons->find($borrowernumber);
my @itemtypes  = Koha::ItemTypes->search_with_localization->as_list;
my %item_types = map { $_->itemtype => $_ } @itemtypes;
$template->param( item_types => \%item_types );

# get the record
my $order = $query->param('order') || '';
if ( $order eq 'title' ) {
    $template->param( orderbytitle => 1 );
} elsif ( $order eq 'author' ) {
    $template->param( orderbyauthor => 1 );
} else {
    $order = { -desc => "date_due" };
    $template->param( orderbydate => 1 );
}

my $limit = $query->param('limit');
$limit //= '';
$limit = ( $limit eq 'full' ) ? 0 : 50;

my $checkouts = [
    $patron->checkouts->search(
        {},
        {
            order_by => $order,
            prefetch => { item => { biblio => 'biblioitems' } },
            ( $limit ? ( rows => $limit ) : () ),
        }
    )->as_list
];
$limit -= scalar(@$checkouts) if $limit;
my $old_checkouts = [
    $patron->old_checkouts->search(
        {},
        {
            order_by => $order,
            prefetch => { item => { biblio => 'biblioitems' } },
            ( $limit ? ( rows => $limit ) : () ),
        }
    )->as_list
];

if ( C4::Context->preference('BakerTaylorEnabled') ) {
    $template->param(
        JacketImages        => 1,
        BakerTaylorImageURL => &image_url(),
        BakerTaylorLinkURL  => &link_url(),
    );
}

my $saving_display = C4::Context->preference('OPACShowSavings');
if ( $saving_display =~ /checkouthistory/ ) {
    $template->param( savings => $patron->get_savings );
}

$template->param(
    checkouts      => $checkouts,
    old_checkouts  => $old_checkouts,
    limit          => $limit,
    readingrecview => 1,
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
