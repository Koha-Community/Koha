package Koha::SearchEngine::Zebra::QueryBuilder;

# This file is part of Koha.
#
# Copyright 2012 BibLibre
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

=head1 NAME

Koha::SearchEngine::Zebra::QueryBuilder - Zebra query objects from user-supplied queries
Several methods are pass-throughs to C4 methods or other methods here

=head1 DESCRIPTION

This provides the functions that take a user-supplied search query, and
provides something that can be given to Zebra to get answers.

=head1 SYNOPSIS

    use Koha::SearchEngine::Zebra::QueryBuilder;
    $builder = Koha::SearchEngine::Zebra::QueryBuilder->new({ index => $index });
    my $simple_query = $builder->build_query("hello");

=head1 METHODS

=cut

use Modern::Perl;

use base qw(Class::Accessor);

use C4::Search;
use C4::AuthoritiesMarc;

=head2 build_query

    Pass-through to C4::Search::buildQuery

=cut

sub build_query {
    shift;
    C4::Search::buildQuery @_;
}

=head2 build_query_compat

    my ($error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$query_type) =
        build_query_compat($operators, $operands, $indexes, $limits, $sort_by, $scan, $lang, $params)

=cut

sub build_query_compat {
    my $self = shift;
    my ( $operators, $operands, $indexes, $limits, $sort_by, $scan, $lang, $params ) = @_;

    my ( $error, $query, $simple_query, $query_cgi, $query_desc, $limit, $limit_cgi, $limit_desc, $query_type ) =
        $self->build_query(@_);

    # add OPAC 'hidelostitems'
    #if (C4::Context->preference('hidelostitems') == 1) {
    #    # either lost ge 0 or no value in the lost register
    #    $query ="($query) and ( (lost,st-numeric <= 0) or ( allrecords,AlwaysMatches='' not lost,AlwaysMatches='') )";
    #}
    #
    # add OPAC suppression - requires at least one item indexed with Suppress
    if ( $params->{suppress} ) {
        if ( defined $query_type and $query_type eq 'pqf' ) {

            #$query = "($query) && -(suppress:1)"; #QP syntax
            $query = '@not ' . $query . ' @attr 14=1 @attr 1=9011 1';    #PQF syntax
        } else {
            $query = "($query) not Suppress=1";
        }
    }

    return ( $error, $query, $simple_query, $query_cgi, $query_desc, $limit, $limit_cgi, $limit_desc, $query_type );
}

=head2 build_authorities_query

    my $query = build_authorities_query( \@query );

=cut

sub build_authorities_query {
    shift;
    return {
        marclist     => $_[0],
        and_or       => $_[1],
        excluding    => $_[2],
        operator     => $_[3],
        value        => $_[4],
        authtypecode => $_[5],
        orderby      => $_[6],
    };
}

=head2 build_authorities_query_compat

   Pass-through to build_authorities_query

=cut

sub build_authorities_query_compat {

    # Pass straight through as well
    build_authorities_query(@_);
}

=head2 clean_search_term

    my $term = $self->clean_search_term($term);

=cut

sub clean_search_term {
    my ( $self, $term ) = @_;

    $term =~ s/"/\\"/g;

    return $term;
}

1;
