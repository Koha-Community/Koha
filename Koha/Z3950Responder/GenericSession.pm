package Koha::Z3950Responder::GenericSession;

# Copyright The National Library of Finland 2018
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use base qw( Koha::Z3950Responder::Session );

use Koha::Logger;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::Z3950Responder::RPN;

=head1 NAME

Koha::Z3950Responder::genericSession

=head1 SYNOPSIS

Backend-agnostic session class that uses C<Koha::Session> as the base class. Utilizes
C<Koha::SearchEngine> for the actual functionality.

=head2 INSTANCE METHODS

=head3 start_search

    my ($resultset, $hits) = $self->start_search( $args, $self->{server}->{num_to_prefetch} );

Perform a search using C<Koha::SearchEngine>'s QueryBuilder and Search.

=cut

sub start_search {
    my ( $self, $args, $num_to_prefetch ) = @_;

    if ( !defined $self->{'attribute_mappings'} ) {
        require YAML::XS;
        $self->{'attribute_mappings'} = YAML::XS::LoadFile( $self->{server}->{config_dir} . 'attribute_mappings.yaml' );
    }

    my $database = $args->{DATABASES}->[0];
    my $builder  = Koha::SearchEngine::QueryBuilder->new( { index => $database } );
    my $searcher = Koha::SearchEngine::Search->new( { index => $database } );

    my $built_query;
    my $query = $args->{RPN}->{'query'}->to_koha( $self->{'attribute_mappings'}->{$database} );
    $self->log_debug("    parsed search: $query");
    my @operands = $query;
    ( undef, $built_query ) = $builder->build_query_compat( undef, \@operands, undef, undef, undef, 0 );

    my ( $error, $marcresults, $hits ) = $searcher->simple_search_compat( $built_query, 0, $num_to_prefetch );
    if ( defined $error ) {
        $self->set_error( $args, $self->ERR_SEARCH_FAILED, 'Search failed' );
        return;
    }

    my $resultset = {
        query          => $built_query,
        database       => $database,
        cached_offset  => 0,
        cached_results => $marcresults,
        hits           => $hits
    };

    return ( $resultset, $hits );
}

=head3 fetch_record

    my $record = $self->fetch_record( $resultset, $args, $offset, $server->{num_to_prefetch} );

Fetch a record from SearchEngine. Caches records in session to avoid too many fetches.

=cut

sub fetch_record {
    my ( $self, $resultset, $args, $index, $num_to_prefetch ) = @_;

    # Fetch more records if necessary
    my $offset = $args->{OFFSET} - 1;
    if ( $offset < $resultset->{cached_offset} || $offset >= $resultset->{cached_offset} + $num_to_prefetch ) {
        $self->log_debug("    fetch uncached, fetching $num_to_prefetch records starting at $offset");
        my $searcher = Koha::SearchEngine::Search->new( { index => $resultset->{'database'} } );
        my ( $error, $marcresults, $num_hits ) =
            $searcher->simple_search_compat( $resultset->{'query'}, $offset, $num_to_prefetch );
        if ( defined $error ) {
            $self->set_error( $args, $self->ERR_TEMPORARY_ERROR, 'Fetch failed' );
            return;
        }

        $resultset->{cached_offset}  = $offset;
        $resultset->{cached_results} = $marcresults;
    }
    return $resultset->{cached_results}[ $offset - $resultset->{cached_offset} ];
}

1;
