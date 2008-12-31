#!/usr/bin/perl

#origninally script to provide intranet (librarian) advanced search facility
#now script to do searching for acquisitions

# Copyright 2000-2002 Katipo Communications
#
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
use C4::Search;
use CGI;
use C4::Bookseller;
use C4::Biblio;

use C4::Auth;
use C4::Output;
use C4::Koha;

my $input = new CGI;

#getting all CGI params into a hash.
my $params = $input->Vars;

my $page             = $params->{'page'} || 1;
my $query            = $params->{'q'};
my $results_per_page = $params->{'num'} || 20;

my $booksellerid = $params->{'booksellerid'};
my $basketno     = $params->{'basketno'};
my $sub          = $params->{'sub'};
my $bookseller = GetBookSellerFromId($booksellerid);

# getting the template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/neworderbiblio.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
    }
);

# Searching the catalog.
my ($error, $marcresults, $total_hits) = SimpleSearch($query, $results_per_page * ($page - 1), $results_per_page);

if (defined $error) {
    warn "error: ".$error;
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

foreach my $i ( 0 .. scalar @$marcresults ) {
    my %resultsloop;
    my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);
    my $biblio = TransformMarcToKoha(C4::Context->dbh,$marcrecord,'');

    #build the hash for the template.
    %resultsloop=%$biblio;
    $resultsloop{highlight}       = ($i % 2)?(1):(0);
    $resultsloop{booksellerid} = $booksellerid;
    push @results, \%resultsloop;
}

$template->param(
    basketno             => $basketno,
    booksellerid     => $bookseller->{'id'},
    name             => $bookseller->{'name'},
    resultsloop          => \@results,
    total                => $total_hits,
    query                => $query,
    pagination_bar       => pagination_bar( "$ENV{'SCRIPT_NAME'}?q=$query&booksellerid=$booksellerid&", getnbpages( $total_hits, $results_per_page ), $page, 'page' ),
);

# BUILD THE TEMPLATE
output_html_with_http_headers $input, $cookie, $template->output;
