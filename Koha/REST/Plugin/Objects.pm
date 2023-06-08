package Koha::REST::Plugin::Objects;

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

use Mojo::Base 'Mojolicious::Plugin';

use JSON;

=head1 NAME

Koha::REST::Plugin::Objects

=head1 API

=head2 Helper methods

=cut

sub register {
    my ( $self, $app ) = @_;

=head3 objects.find

    my $patrons_rs = Koha::Patrons->new;
    my $patrons = $c->objects->find( $patrons_rs, $id );
    . . .
    return $c->render({ status => 200, openapi => $patron });

Performs a database search using given Koha::Objects object and the $id.

Returns I<undef> if no object is found or the I<API representation> of
the requested object including any embeds specified in the request.

=cut

    $app->helper(
        'objects.find' => sub {
            my ( $c, $result_set, $id ) = @_;
            my $object = $c->objects->find_rs( $result_set, $id );
            return unless $object;
            return $c->objects->to_api($object);
        }
    );


=head3 objects.find_rs

    my $patrons_rs = Koha::Patrons->new;
    my $patron_rs = $c->objects->find_rs( $patrons_rs, $id );
    . . .
    return $c->render({ status => 200, openapi => $patron_rs->to_api });

Returns the passed Koha::Object result filtered to the passed $id and
with any embeds requested by the api applied.

The result object can then be used for further processing.

=cut

    $app->helper(
        'objects.find_rs' => sub {
            my ( $c, $result_set, $id ) = @_;

            my $attributes = {};

            # Generate prefetches for embedded stuff
            $c->dbic_merge_prefetch(
                {
                    attributes => $attributes,
                    result_set => $result_set
                }
            );

            my $object = $result_set->find( $id, $attributes );

            return $object;
        }
    );

=head3 objects.search

    my $patrons_rs = Koha::Patrons->new;
    my $patrons = $c->objects->search( $patrons_rs );
    . . .
    return $c->render({ status => 200, openapi => $patrons });

Performs a database search using given Koha::Objects object with any api
query parameters applied.

Returns an arrayref of I<API representations> of the requested objects
including any embeds specified in the request.

Warning: this helper adds pagination headers to the calling controller, and thus
shouldn't be called twice in it.

=cut

    $app->helper(
        'objects.search' => sub {
            my ( $c, $result_set, $query_fixers ) = @_;

            # Generate the resultset using the HTTP request information
            my $objects_rs = $c->objects->search_rs( $result_set, $query_fixers );

            # Add pagination headers
            $c->add_pagination_headers();

            return $c->objects->to_api($objects_rs);
        }
    );

=head3 objects.search_rs

    my $patrons_object = Koha::Patrons->new;
    my $patrons_rs = $c->objects->search_rs( $patrons_object [, $query_fixers ] );
    . . .
    return $c->render({ status => 200, openapi => $patrons_rs->to_api });

Returns the passed Koha::Objects resultset filtered as requested by the api query
parameters and with requested embeds applied.

The optional I<$query_fixers> parameter is expected to be a reference to a list of
function references. This functions need to accept two parameters: ( $query, $no_quotes ).

The I<$query> is a string to be adapted. A modified version will be returned. The
I<$no_quotes> parameter controls if quotes need to be added for matching inside the string.
Quoting should be used by default, for replacing JSON keys e.g "biblio.isbn" would match
and biblio.isbn wouldn't.

Warning: this helper stashes base values for the pagination headers to the calling
controller, and thus shouldn't be called twice in it.

=cut

    $app->helper(
        'objects.search_rs' => sub {
            my ( $c, $result_set, $query_fixers ) = @_;

            my $args       = $c->validation->output;
            my $attributes = {};

            $query_fixers //= [];

            # Extract reserved params
            my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($args);

            if ( exists $reserved_params->{_order_by} ) {

                # convert to arrayref if it is a single param, to keep code simple
                $reserved_params->{_order_by} = [ $reserved_params->{_order_by} ]
                    unless ref( $reserved_params->{_order_by} ) eq 'ARRAY';

                # _order_by passed, fix if required
                for my $p ( @{ $reserved_params->{_order_by} } ) {
                    foreach my $qf ( @{$query_fixers} ) {
                        $p = $qf->( $p, 1 );    # 1 => no quotes on matching
                    }
                }
            }

            # Merge sorting into query attributes
            $c->dbic_merge_sorting(
                {
                    attributes => $attributes,
                    params     => $reserved_params,
                    result_set => $result_set
                }
            );

            # If no pagination parameters are passed, default
            $reserved_params->{_per_page} //=
              C4::Context->preference('RESTdefaultPageSize') // 20;
            $reserved_params->{_page} //= 1;

            $c->stash('koha.pagination.page'     => $reserved_params->{_page});
            $c->stash('koha.pagination.per_page' => $reserved_params->{_per_page});

            unless ( $reserved_params->{_per_page} == -1 ) {

                # Merge pagination into query attributes
                $c->dbic_merge_pagination(
                    {
                        filter => $attributes,
                        params => $reserved_params
                    }
                );
            }

            # Generate prefetches for embedded stuff
            $c->dbic_merge_prefetch(
                {
                    attributes => $attributes,
                    result_set => $result_set
                }
            );

            # Call the to_model function by reference, if defined
            if ( defined $filtered_params ) {

                # Apply the mapping function to the passed params
                $filtered_params =
                  $result_set->attributes_from_api($filtered_params);
                $filtered_params =
                  $c->build_query_params( $filtered_params, $reserved_params );
            }

            if (   defined $reserved_params->{q}
                || defined $reserved_params->{query} )
            {
                $filtered_params //= {};

                my @query_params_array;

                my $json = JSON->new;

                # query in request body, JSON::Validator already decoded it
                if ( $reserved_params->{query} ) {
                    my $query = $json->encode( $reserved_params->{query} );
                    foreach my $qf ( @{$query_fixers} ) {
                        $query = $qf->($query);
                    }
                    push @query_params_array, $json->decode($query);
                }

                if ( ref( $reserved_params->{q} ) eq 'ARRAY' ) {

                   # q is defined as multi => JSON::Validator generates an array
                    foreach my $q ( @{ $reserved_params->{q} } ) {
                        if ( $q ) { # skip if exists but is empty
                            foreach my $qf (@{$query_fixers}) {
                                $q = $qf->($q);
                            }
                            push @query_params_array, $json->decode($q);
                        }
                    }
                }
                else {
                    # objects.search called outside OpenAPI context
                    # might be a hashref
                    if ( $reserved_params->{q} ) {
                        my $q = $reserved_params->{q};
                        foreach my $qf (@{$query_fixers}) {
                            $q = $qf->($q);
                        }
                        push @query_params_array, $json->decode( $q );
                    }
                }

                my $query_params;

                if ( scalar(@query_params_array) > 1 ) {
                    $query_params = { '-and' => \@query_params_array };
                }
                else {
                    $query_params = $query_params_array[0];
                }

                $filtered_params =
                  $c->merge_q_params( $filtered_params, $query_params,
                    $result_set );
            }

            # request sequence id (i.e. 'draw' Datatables parameter)
            $c->res->headers->add(
                'x-koha-request-id' => $reserved_params->{'x-koha-request-id'} )
              if $reserved_params->{'x-koha-request-id'};

            # If search_limited exists, use it
            $result_set = $result_set->search_limited,
              if $result_set->can('search_limited');

            $c->stash('koha.pagination.base_total'   => $result_set->count);
            $c->stash('koha.pagination.query_params' => $args);

            # Generate the resultset
            my $objects_rs = $result_set->search( $filtered_params, $attributes );
            # Stash the page total if requires, total otherwise
            $c->stash('koha.pagination.total' => $objects_rs->is_paged ? $objects_rs->pager->total_entries : $objects_rs->count);

            return $objects_rs;
        }
    );

=head3 objects.to_api

    my $patrons_rs = Koha::Patrons->new;
    my $api_representation = $c->objects->to_api( $patrons_rs );

Returns the API representation of the passed resultset.

=cut

    $app->helper(
        'objects.to_api' => sub {
            my ( $c, $object ) = @_;

            # Privileged request?
            my $public = $c->stash('is_public');

            # Look for embeds
            my $embed   = $c->stash('koha.embed');
            my $strings = $c->stash('koha.strings');

            return $object->to_api(
                {
                    embed   => $embed,
                    public  => $public,
                    strings => $strings
                }
            );
        }
    );
}

1;
