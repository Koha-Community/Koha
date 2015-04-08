#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
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

=head1 cataloguing:addbooks.pl

	TODO

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Biblio;
use C4::Breeding;
use C4::Output;
use C4::Koha;
use C4::Search;

my $input = new CGI;

my $success = $input->param('biblioitem');
my $query   = $input->param('q');
my @value   = $input->param('value');
my $page    = $input->param('page') || 1;
my $results_per_page = 20;


my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/addbooks.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => '*' },
        debug           => 1,
    }
);

# get framework list
my $frameworks = getframeworks;
my @frameworkcodeloop;
foreach my $thisframeworkcode ( sort { uc($frameworks->{$a}->{'frameworktext'}) cmp uc($frameworks->{$b}->{'frameworktext'}) } keys %{$frameworks} ) {
    push @frameworkcodeloop, {
        value         => $thisframeworkcode,
        frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
    };
}


# Searching the catalog.
if ($query) {

    # build query
    my @operands = $query;

    my $QParser;
    $QParser = C4::Context->queryparser if (C4::Context->preference('UseQueryParser'));
    my $builtquery;
    if ($QParser) {
        $builtquery = $query;
    } else {
        my ( $builterror,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type);
        ( $builterror,$builtquery,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type) = buildQuery(undef,\@operands);
    }

    # find results
    my ( $error, $marcresults, $total_hits ) = SimpleSearch($builtquery, $results_per_page * ($page - 1), $results_per_page);

    if ( defined $error ) {
        $template->param( error => $error );
        warn "error: " . $error;
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }

    # format output
    # SimpleSearch() give the results per page we want, so 0 offet here
    my $total = @{$marcresults};
    my @newresults = searchResults( 'intranet', $query, $total, $results_per_page, 0, 0, $marcresults );
    $template->param(
        total          => $total_hits,
        query          => $query,
        resultsloop    => \@newresults,
        pagination_bar => pagination_bar( "/cgi-bin/koha/cataloguing/addbooks.pl?q=$query&", getnbpages( $total_hits, $results_per_page ), $page, 'page' ),
    );
}

# fill with books in breeding farm

my $countbr = 0;
my @resultsbr;
if ($query) {
# fill isbn or title, depending on what has been entered
#u must do check on isbn because u can find number in beginning of title
#check is on isbn legnth 13 for new isbn and 10 for old isbn
    my ( $title, $isbn );
    if ($query=~/\d/) {
        my $clean_query = $query;
        $clean_query =~ s/-//g; # remove hyphens
        my $querylength = length $clean_query;
        if ( $querylength == 13 || $querylength == 10 ) {
            $isbn = $query;
        }
    }
    if (!$isbn) {
        $title = $query;
    }
    ( $countbr, @resultsbr ) = BreedingSearch( $title, $isbn );
}
my $breeding_loop = [];
for my $resultsbr (@resultsbr) {
    push @{$breeding_loop}, {
        id               => $resultsbr->{import_record_id},
        isbn             => $resultsbr->{isbn},
        copyrightdate    => $resultsbr->{copyrightdate},
        editionstatement => $resultsbr->{editionstatement},
        file             => $resultsbr->{file_name},
        title            => $resultsbr->{title},
        author           => $resultsbr->{author},
    };
}

$template->param(
    frameworkcodeloop => \@frameworkcodeloop,
    breeding_count    => $countbr,
    breeding_loop     => $breeding_loop,
    z3950_search_params => C4::Search::z3950_search_args($query),
);

output_html_with_http_headers $input, $cookie, $template->output;

