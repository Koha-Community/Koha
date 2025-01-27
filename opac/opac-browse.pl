#!/usr/bin/perl

# This is a CGI script that handles the browse feature.

# Copyright 2015 Catalyst IT
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

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );

use Koha::SearchEngine::Elasticsearch;
use Koha::SearchEngine::Elasticsearch::Browse;
use Koha::SearchEngine::Elasticsearch::QueryBuilder;
use Koha::SearchEngine::Elasticsearch::Search;

use JSON qw( to_json );
use Unicode::Collate;

my $query = CGI->new;
binmode STDOUT, ':encoding(UTF-8)';

# If calling via JS, 'api' is used to route to correct step in process
my $api = $query->param('api');

if ( !$api ) {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-browse.tt",
            query           => $query,
            type            => "opac",
            authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        }
    );
    $template->param();
    output_html_with_http_headers $query, $cookie, $template->output;

} elsif ( $api eq 'GetSuggestions' ) {
    my $fuzzie = $query->param('fuzziness');
    my $prefix = $query->param('prefix');
    my $field  = $query->param('field');

    # Under a persistent environment, we should probably not reinit this every time.
    my $browser = Koha::SearchEngine::Elasticsearch::Browse->new( { index => 'biblios' } );
    my $res     = $browser->browse( $prefix, $field, { fuzziness => $fuzzie } );

    my %seen;
    my @sorted =
        grep { !$seen{ $_->{text} }++ }
        sort { lc( $a->{text} ) cmp lc( $b->{text} ) } @$res;
    print CGI::header(
        -type    => 'application/json',
        -charset => 'utf-8'
    );
    print to_json( \@sorted );
} elsif ( $api eq 'GetResults' ) {
    my $term  = $query->param('term');
    my $field = $query->param('field');

    my $builder  = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'biblios' } );
    my $searcher = Koha::SearchEngine::Elasticsearch::Search->new(
        { index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX } );

    my $query   = { query => { term => { $field . ".raw" => $term } } };
    my $results = $searcher->search( $query, undef, 500 );
    my @output  = _filter_for_output( $results->{hits}->{hits} );
    print CGI::header(
        -type    => 'application/json',
        -charset => 'utf-8'
    );
    print to_json( \@output );
}

# This should probably be done with some templatey gizmo
# in the future.
sub _filter_for_output {
    my ($records) = @_;
    my @output;
    foreach my $rec (@$records) {
        my $biblionumber = $rec->{_id};
        my $biblio       = Koha::Biblios->find($biblionumber);
        next unless $biblio;
        push @output,
            {
            id       => $biblionumber,
            title    => $biblio->title,
            subtitle => $biblio->subtitle,
            author   => $biblio->author,
            };
    }
    my @sorted = sort { lc( $a->{title} ) cmp lc( $b->{title} ) } @output;
    return @sorted;
}
