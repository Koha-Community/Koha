#!/usr/bin/perl

#origninally script to provide intranet (librarian) advanced search facility
#now script to do searching for acquisitions

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
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

=head1 NAME

neworderbiblio.pl

=head1 DESCRIPTION

this script allows to perform a new order from an existing record.

=head1 CGI PARAMETERS

=over 4

=item search
the title the librarian has typed to search an existing record.

=item q
the keyword the librarian has typed to search an existing record.

=item author
the author of the new record.

=item num
the number of result per page to display

=item booksellerid
the id of the bookseller this script has to add an order.

=item basketno
the basket number to know on which basket this script have to add a new order.

=back

=cut

use strict;
#use warnings; FIXME - Bug 2505

use C4::Search;
use CGI;
use C4::Bookseller qw/ GetBookSellerFromId /;
use C4::Biblio;
use C4::Auth;
use C4::Output;
use C4::Koha;
use C4::Members qw/ GetMember /;
use C4::Budgets qw/ GetBudgetHierarchy /;

my $input = new CGI;

#getting all CGI params into a hash.
my $params = $input->Vars;

my $page             = $params->{'page'} || 1;
my $query            = $params->{'q'};
my $results_per_page = $params->{'num'} || 20;
my $booksellerid     = $params->{'booksellerid'};
my $basketno         = $params->{'basketno'};
my $sub              = $params->{'sub'};
my $bookseller = GetBookSellerFromId($booksellerid);

# getting the template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/neworderbiblio.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

# Searching the catalog.

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
my ( $error, $marcresults, $total_hits ) = SimpleSearch( $builtquery, $results_per_page * ( $page - 1 ), $results_per_page );

if (defined $error) {
    $template->param(
        query_error => $error,
        basketno             => $basketno,
        booksellerid     => $bookseller->{'id'},
        name             => $bookseller->{'name'},
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my @results;

foreach my $result ( @{$marcresults} ) {
    my $marcrecord = C4::Search::new_record_from_zebra( 'biblioserver', $result );
    my $biblio = TransformMarcToKoha( C4::Context->dbh, $marcrecord, '' );

    $biblio->{booksellerid} = $booksellerid;
    push @results, $biblio;

}

my $borrower= GetMember('borrowernumber' => $loggedinuser);
my $budgets = GetBudgetHierarchy(q{},$borrower->{branchcode},$borrower->{borrowernumber});
my $has_budgets = 0;
foreach my $r (@{$budgets}) {
    if (!defined $r->{budget_amount} || $r->{budget_amount} == 0) {
        next;
    }
    $has_budgets = 1;
    last;
}

$template->param(
    has_budgets          => $has_budgets,
    basketno             => $basketno,
    booksellerid         => $bookseller->{'id'},
    name                 => $bookseller->{'name'},
    resultsloop          => \@results,
    total                => $total_hits,
    query                => $query,
    pagination_bar       => pagination_bar( "$ENV{'SCRIPT_NAME'}?q=$query&booksellerid=$booksellerid&basketno=$basketno&", getnbpages( $total_hits, $results_per_page ), $page, 'page' ),
);

# BUILD THE TEMPLATE
output_html_with_http_headers $input, $cookie, $template->output;
