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

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::Circulation;
use C4::Review;
use C4::Biblio;
use C4::Dates;
use C4::Members qw/GetMemberDetails/;
use POSIX qw(ceil strftime);

my $template_name;
my $query = new CGI;
my $format = $query->param("format") || '';
my $count = C4::Context->preference('OPACnumSearchResults') || 20;
my $results_per_page = $query->param('count') || $count;
my $offset = $query->param('offset') || 0;
my $page = $query->param('page') || 1;
$offset = ($page-1)*$results_per_page if $page>1;

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
    my $lastbuilddate = C4::Dates->new();
    my $lastbuilddate_output = $lastbuilddate->output("rfc822");
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

my $reviews = getallreviews(1,$offset,$results_per_page);
my $marcflavour      = C4::Context->preference("marcflavour");
my $hits = numberofreviews(1);
my $i = 0;
my $latest_comment_date;
for my $result (@$reviews){
    my $biblionumber = $result->{biblionumber};
	my $bib = &GetBiblioData($biblionumber);
    my $record = GetMarcBiblio($biblionumber);
    my $frameworkcode = GetFrameworkCode($biblionumber);
	my ( $borr ) = GetMemberDetails( $result->{borrowernumber} );
	$result->{normalized_upc} = GetNormalizedUPC($record,$marcflavour);
	$result->{normalized_ean} = GetNormalizedEAN($record,$marcflavour);
	$result->{normalized_oclc} = GetNormalizedOCLCNumber($record,$marcflavour);
	$result->{normalized_isbn} = GetNormalizedISBN(undef,$record,$marcflavour);
	$result->{title} = $bib->{'title'};
	$result->{subtitle} = GetRecordValue('subtitle', $record, $frameworkcode);
	$result->{author} = $bib->{'author'};
	$result->{place} = $bib->{'place'};
	$result->{publishercode} = $bib->{'publishercode'};
	$result->{copyrightdate} = $bib->{'copyrightdate'};
	$result->{pages} = $bib->{'pages'};
	$result->{size} = $bib->{'size'};
	$result->{notes} = $bib->{'notes'};
	$result->{timestamp} = $bib->{'timestamp'};
    $result->{borrtitle} = $borr->{'title'};
	$result->{firstname} = $borr->{'firstname'};
	$result->{surname} = $borr->{'surname'};
    $result->{userid} = $borr->{'userid'};
        if ($libravatar_enabled and $borr->{'email'}) {
            $result->{avatarurl} = libravatar_url(email => $borr->{'email'}, size => 40, https => $ENV{HTTPS});
        }

    if ($result->{borrowernumber} eq $borrowernumber) {
		$result->{your_comment} = 1;
	}

    if($format eq "rss"){
        my $rsstimestamp = C4::Dates->new($result->{datereviewed},"iso");
        my $rsstimestamp_output = $rsstimestamp->output("rfc822");
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
);

output_html_with_http_headers $query, $cookie, $template->output;
