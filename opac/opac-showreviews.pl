#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Parts copyright 2010 Nelsonville Public Library
#
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
use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::Circulation;
use C4::Biblio;
use Koha::DateUtils;
use Koha::Patrons;
use Koha::Reviews;
use POSIX qw(ceil floor strftime);

my $template_name;
my $query = new CGI;
my $format = $query->param("format") || '';
my $count = C4::Context->preference('OPACnumSearchResults') || 20;
my $results_per_page = $query->param('count') || $count;
my $offset = $query->param('offset') || 0;
my $page = floor( $offset / $results_per_page ) + 1;

if ($format eq "rss") {
    $template_name = "opac-showreviews-rss.tt";
} else {
    $template_name = "opac-showreviews.tt",
}

my ( $template, $borrowernumber, $cookie ) = &get_template_and_user(
    {
        template_name   => $template_name,
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

if($format eq "rss"){
    my $lastbuilddate = dt_from_string;
    my $lastbuilddate_output = $lastbuilddate->strftime("%a, %d %b %Y %H:%M:%S %z");
    $template->param(
        rss => 1,
        timestamp => $lastbuilddate_output
        );
}

my $libravatar_enabled = 0;
if ( C4::Context->preference('ShowReviewer') and C4::Context->preference('ShowReviewerPhoto')) {
    eval {
        require Libravatar::URL;
        Libravatar::URL->import();
    };
    if ( !$@ ) {
        $libravatar_enabled = 1;
    }
}

my $reviews = Koha::Reviews->search(
    { approved => 1 },
    {
        rows => $results_per_page,
        page => $page,
        order_by => { -desc => 'datereviewed' },
    }
)->unblessed;
my $marcflavour      = C4::Context->preference("marcflavour");
my $hits = Koha::Reviews->search({ approved => 1 })->count;
my $i = 0;
my $latest_comment_date;
for my $result (@$reviews){
    my $biblionumber = $result->{biblionumber};
    my $biblio = Koha::Biblios->find( $biblionumber );
    my $biblioitem = $biblio->biblioitem;
    my $record = GetMarcBiblio({ biblionumber => $biblionumber });
    my $frameworkcode = GetFrameworkCode($biblionumber);
	$result->{normalized_upc} = GetNormalizedUPC($record,$marcflavour);
	$result->{normalized_ean} = GetNormalizedEAN($record,$marcflavour);
	$result->{normalized_oclc} = GetNormalizedOCLCNumber($record,$marcflavour);
	$result->{normalized_isbn} = GetNormalizedISBN(undef,$record,$marcflavour);
    $result->{title} = $biblio->title;
	$result->{subtitle} = GetRecordValue('subtitle', $record, $frameworkcode);
    $result->{author} = $biblio->author;
    $result->{place} = $biblioitem->place;
    $result->{publishercode} = $biblioitem->publishercode;
    $result->{copyrightdate} = $biblio->copyrightdate;
    $result->{pages} = $biblioitem->pages;
    $result->{size} = $biblioitem->size;
    $result->{notes} = $biblioitem->notes;
    $result->{timestamp} = $biblioitem->timestamp;

    my $patron = Koha::Patrons->find( $result->{borrowernumber} );
    if ( $patron ) {
        $result->{borrtitle} = $patron->title;
        $result->{firstname} = $patron->firstname;
        $result->{surname} = $patron->surname;
        $result->{userid} = $patron->userid;
            if ($libravatar_enabled and $patron->email) {
                $result->{avatarurl} = libravatar_url(email => $patron->email, size => 40, https => $ENV{HTTPS});
            }

        if ($result->{borrowernumber} eq $borrowernumber) {
            $result->{your_comment} = 1;
        }
    }

    if($format eq "rss"){
        my $rsstimestamp = eval { dt_from_string( $result->{datereviewed} ); };
        $rsstimestamp = dt_from_string unless ( $rsstimestamp ); #default to today if something went wrong
        my $rsstimestamp_output = $rsstimestamp->strftime("%a, %d %b %Y %H:%M:%S %z");
        $result->{timestamp} = $rsstimestamp_output;
    }
}
## Build the page numbers on the bottom of the page
            my @page_numbers;
            my $previous_page_first;
            my $previous_page_offset;
            # total number of pages there will be
            my $pages = ceil($hits / $results_per_page);
            # default page number
            my $current_page_number = 1;
            $current_page_number = ($offset / $results_per_page + 1) if $offset;
            if($offset - $results_per_page == 0){
                $previous_page_first = 1;
            } elsif ($offset - $results_per_page > 0){
                $previous_page_offset = $offset - $results_per_page;
            }
            my $next_page_offset = $offset + $results_per_page;
            # If we're within the first 10 pages, keep it simple
            if ($current_page_number < 10) {
                # just show the first 10 pages
                # Loop through the pages
                my $pages_to_show = 10;
                $pages_to_show = $pages if $pages<10;
                for ($i=1; $i<=$pages_to_show;$i++) {
                    # the offset for this page
                    my $this_offset = (($i*$results_per_page)-$results_per_page);
                    # the page number for this page
                    my $this_page_number = $i;
                    # it should only be highlighted if it's the current page
                    my $highlight;
            $highlight = 1 if ($this_page_number == $current_page_number);
                    # put it in the array
                    push @page_numbers, { offset => $this_offset, pg => $this_page_number, highlight => $highlight };

                }

            }
            # now, show twenty pages, with the current one smack in the middle
            else {
                for ($i=$current_page_number; $i<=($current_page_number + 20 );$i++) {
                    my $this_offset = ((($i-9)*$results_per_page)-$results_per_page);
                    my $this_page_number = $i-9;
                    my $highlight;
            $highlight = 1 if ($this_page_number == $current_page_number);
                    if ($this_page_number <= $pages) {
                        push @page_numbers, { offset => $this_offset, pg => $this_page_number, highlight => $highlight };
                    }
                }
            }
$template->param(   PAGE_NUMBERS => \@page_numbers,
                    previous_page_first => $previous_page_first,
                    previous_page_offset => $previous_page_offset) unless $pages < 2;
$template->param(next_page_offset => $next_page_offset) unless $pages eq $current_page_number;

$template->param(
    reviews => $reviews,
    results_per_page => $results_per_page,
);

output_html_with_http_headers $query, $cookie, $template->output;
