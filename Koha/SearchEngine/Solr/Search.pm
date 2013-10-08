package Koha::SearchEngine::Solr::Search;

# This file is part of Koha.
#
# Copyright 2012 BibLibre
# Copyright 2012 KohaAloha
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

use Moose::Role;
with 'Koha::SearchEngine::SearchRole';

use Data::Dump qw(dump);
use XML::Simple;

use Data::SearchEngine::Solr;
use Data::Pagination;
use Data::SearchEngine::Query;
use Koha::SearchEngine::Solr;

has searchengine => (
    is => 'rw',
    isa => 'Koha::SearchEngine::Solr',
    default => sub { Koha::SearchEngine::Solr->new },
    lazy => 1
);

sub search {
    my ( $self, $q, $filters, $params ) = @_;

    $q         ||= '*:*';
    $filters   ||= {};
    my $page   = defined $params->{page}   ? $params->{page}   : 1;
    my $count  = defined $params->{count}  ? $params->{count}  : 999999999;
    my $sort   = defined $params->{sort}   ? $params->{sort}   : 'score desc';
    my $facets = defined $params->{facets} ? $params->{facets} : 0;

    # Construct fl from $params->{fl}
    # If "recordid" or "id" not exist, we push them
    my $fl = join ",",
        defined $params->{fl}
            ? (
                @{$params->{fl}},
                grep ( /^recordid$/, @{$params->{fl}} ) ? () : "recordid",
                grep ( /^id$/, @{$params->{fl}} ) ? () : "id"
              )
            : ( "recordid", "id" );

    my $recordtype;
    $recordtype = ref($filters->{recordtype}) eq 'ARRAY'
                    ? $filters->{recordtype}[0]
                    : $filters->{recordtype}
                if defined $filters && defined $filters->{recordtype};

    if ( $facets ) {
        $self->searchengine->options->{"facet"}          = 'true';
        $self->searchengine->options->{"facet.mincount"} = 1;
        $self->searchengine->options->{"facet.limit"}    = 10; # TODO create a new systempreference C4::Context->preference("numFacetsDisplay")
        my @facetable_indexes = map { 'str_' . $_->{code} } @{$self->searchengine->config->facetable_indexes};
        $self->searchengine->options->{"facet.field"}    = \@facetable_indexes;
    }
    $self->searchengine->options->{sort} = $sort;
    $self->searchengine->options->{fl} = $fl;

    # Construct filters
    $self->searchengine->options->{fq} = [
        map {
            my $idx = $_;
            ref($filters->{$idx}) eq 'ARRAY'
                ?
                    '('
                    . join( ' AND ',
                        map {
                            my $filter_str = $_;
                            utf8::decode($filter_str);
                            my $quotes_existed = ( $filter_str =~ m/^".*"$/ );
                            $filter_str =~ s/^"(.*)"$/$1/; #remove quote around value if exist
                            $filter_str =~ s/[^\\]\K"/\\"/g;
                            $filter_str = qq{"$filter_str"} # Add quote around value if not exist
                                if not $filter_str =~ /^".*"$/
                                    and $quotes_existed;
                            qq{$idx:$filter_str};
                        } @{ $filters->{$idx} } )
                    . ')'
                : "$idx:$filters->{$idx}";
        } keys %$filters
    ];

    my $sq = Data::SearchEngine::Query->new(
        page  => $page,
        count => $count,
        query => $q,
    );

    # Get results
    my $results = eval { $self->searchengine->search( $sq ) };

    # Get error if exists
    if ( $@ ) {
        my $err = $@;

        $err =~ s#^[^\n]*\n##; # Delete first line
        if ( $err =~ "400 URL must be absolute" ) {
            $err = "Your system preference 'SolrAPI' is not set correctly";
        }
        elsif ( not $err =~ 'Connection refused' ) {
            my $document = XMLin( $err );
            $err = "$$document{body}{h2} : $$document{body}{pre}";
        }
        $results->{error} = $err;
    }
    return $results;
}

sub dosmth {'bou' }

1;
