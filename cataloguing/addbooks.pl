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

=cut

use Modern::Perl;

use CGI          qw ( -utf8 );
use C4::Auth     qw( get_template_and_user );
use C4::Breeding qw( BreedingSearch );
use C4::Output   qw( output_html_with_http_headers pagination_bar );
use C4::Koha     qw( getnbpages );
use C4::Languages;
use C4::Search qw( searchResults z3950_search_args );

use Koha::BiblioFrameworks;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::Z3950Servers;

my $input = CGI->new;

my $success          = $input->param('biblioitem');
my $query            = $input->param('q');
my @value            = $input->multi_param('value');
my $page             = $input->param('page') || 1;
my $results_per_page = 20;
my $lang             = C4::Languages::getlanguage($input);

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "cataloguing/addbooks.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { editcatalogue => '*' },
    }
);

# Searching the catalog.
if ($query) {

    # build query
    my @operands = $query;

    my $builtquery;
    my $query_cgi;
    my $builder  = Koha::SearchEngine::QueryBuilder->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
    my $searcher = Koha::SearchEngine::Search->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
    ( undef, $builtquery, undef, $query_cgi, undef, undef, undef, undef, undef, undef ) =
        $builder->build_query_compat( undef, \@operands, undef, undef, undef, 0, $lang, { weighted_fields => 1 } );

    $template->param( search_query => $builtquery ) if C4::Context->preference('DumpSearchQueryTemplate');

    # find results
    my ( $error, $marcresults, $total_hits ) =
        $searcher->simple_search_compat( $builtquery, $results_per_page * ( $page - 1 ), $results_per_page );

    if ( defined $error ) {
        $template->param( error => $error );
        warn "error: " . $error;
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }

    # format output
    # SimpleSearch() give the results per page we want, so 0 offset here
    my $total = @{$marcresults};
    my @newresults =
        searchResults( { 'interface' => 'intranet' }, $query, $total, $results_per_page, 0, 0, $marcresults );
    foreach my $line (@newresults) {
        if ( not exists $line->{'size'} ) { $line->{'size'} = "" }
    }
    $template->param(
        total          => $total_hits,
        query          => $query,
        resultsloop    => \@newresults,
        pagination_bar => pagination_bar(
            "/cgi-bin/koha/cataloguing/addbooks.pl?$query_cgi&", getnbpages( $total_hits, $results_per_page ), $page,
            'page'
        ),
    );
}

# fill with books in breeding farm

my $countbr = 0;
my @resultsbr;
if ($query) {
    ( $countbr, @resultsbr ) = BreedingSearch($query);
}
my $breeding_loop = [];
for my $resultsbr (@resultsbr) {
    push @{$breeding_loop}, {
        id               => $resultsbr->{import_record_id},
        isbn             => $resultsbr->{isbn},
        file             => $resultsbr->{file_name},
        title            => $resultsbr->{title},
        author           => $resultsbr->{author},
        upload_timestamp => $resultsbr->{upload_timestamp}
    };
}

my $servers = Koha::Z3950Servers->search(
    {
        recordtype => 'biblio',
        servertype => [ 'zed', 'sru' ],
    }
);

my $frameworks = Koha::BiblioFrameworks->search( {}, { order_by => ['frameworktext'] } );
$template->param(
    servers             => $servers,
    frameworks          => $frameworks,
    breeding_count      => $countbr,
    breeding_loop       => $breeding_loop,
    z3950_search_params => C4::Search::z3950_search_args($query),
);

output_html_with_http_headers $input, $cookie, $template->output;

