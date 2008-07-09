#!/usr/bin/perl


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

=head1 cataloguing:addbooks.pl

	TODO

=cut

use strict;
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
        template_name   => "cataloguing/addbooks.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);

# get framework list
my $frameworks = getframeworks;
my @frameworkcodeloop;
foreach my $thisframeworkcode ( keys %$frameworks ) {
    my %row = (
        value         => $thisframeworkcode,
        frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
    );
    push @frameworkcodeloop, \%row;
}

# Searching the catalog.
if ($query) {

    # find results
    my ( $error, $marcresults, $total_hits ) = SimpleSearch($query, $results_per_page * ($page - 1), $results_per_page);

    if ( defined $error ) {
        $template->param( error => $error );
        warn "error: " . $error;
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }
    
    # format output
    my $total = scalar @$marcresults;
    my @newresults = searchResults( $query, $total, $results_per_page, $page-1, 0, @$marcresults );
    $template->param(
        total          => $total_hits,
        query          => $query,
        resultsloop    => \@newresults,
        # FIXME: pagination_bar doesn't work right with only one pair of CGI params, so I put two in.
        pagination_bar => pagination_bar( "/cgi-bin/koha/cataloguing/addbooks.pl?bug=fix&q=$query&", getnbpages( $total_hits, $results_per_page ), $page, 'page' ),
    );
}

# fill with books in breeding farm
my $toggle = 0;
my ( $title, $isbn );

# fill isbn or title, depending on what has been entered
#u must do check on isbn because u can find number in beginning of title
#check is on isbn legnth 13 for new isbn and 10 for old isbn
my $querylength = length($query);
if ( $query =~ /\d/ and ( $querylength eq 13 or $querylength eq 10 ) ) {
    $isbn = $query;
}
$title = $query unless $isbn;
my ( $countbr, @resultsbr ) = BreedingSearch( $title, $isbn ) if $query;
my @breeding_loop = ();
for ( my $i = 0 ; $i <= $#resultsbr ; $i++ ) {
    my %row_data;
    if ( $i % 2 ) {
        $toggle = 0;
    }
    else {
        $toggle = 1;
    }
    $row_data{toggle} = $toggle;
    $row_data{id}     = $resultsbr[$i]->{'id'};
    $row_data{isbn}   = $resultsbr[$i]->{'isbn'};
    $row_data{file}   = $resultsbr[$i]->{'file'};
    $row_data{title}  = $resultsbr[$i]->{'title'};
    $row_data{author} = $resultsbr[$i]->{'author'};
    push( @breeding_loop, \%row_data );
}

$template->param(
    frameworkcodeloop => \@frameworkcodeloop,
    breeding_count    => $countbr,
    breeding_loop     => \@breeding_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
