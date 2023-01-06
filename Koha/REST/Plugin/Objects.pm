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
the requested object. It passes through any embeds if specified.

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

Returns the passed Koha::Objects resultset filtered to the passed $id and
with any embeds requested by the api applied.

The resultset can then be used for further processing.

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

Returns an arrayref of the hashrefs representing the resulting objects
for API rendering.

Warning: this helper adds pagination headers to the calling controller, and thus
shouldn't be called twice in it.

=cut

    $app->helper(
        'objects.search' => sub {
            my ( $c, $result_set ) = @_;

            return $c->objects->to_api( $c->objects->search_rs($result_set) );
        }
    );

=head3 objects.search_rs

    my $patrons_rs = Koha::Patrons->new;
    my $patrons_rs = $c->objects->search_rs( $patrons_rs );
    . . .
    return $c->render({ status => 200, openapi => $patrons_rs->to_api });

Returns the passed Koha::Objects resultset filtered as requested by the api query
parameters and with requested embeds applied.

Warning: this helper adds pagination headers to the calling controller, and thus
shouldn't be called twice in it.

=cut

    $app->helper(
        'objects.search_rs' => sub {
            my ( $c, $result_set ) = @_;

            my $args       = $c->validation->output;
            my $attributes = {};

            # Extract reserved params
            my ( $filtered_params, $reserved_params, $path_params ) =
              $c->extract_reserved_params($args);

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
              C4::Context->preference('RESTdefaultPageSize');
            $reserved_params->{_page} //= 1;

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
                || defined $reserved_params->{query}
                || defined $reserved_params->{'x-koha-query'} )
            {
                $filtered_params //= {};

                my @query_params_array;

                # query in request body, JSON::Validator already decoded it
                push @query_params_array, $reserved_params->{query}
                  if defined $reserved_params->{query};

                my $json = JSON->new;

                if ( ref( $reserved_params->{q} ) eq 'ARRAY' ) {

                   # q is defined as multi => JSON::Validator generates an array
                    foreach my $q ( @{ $reserved_params->{q} } ) {
                        push @query_params_array, $json->decode($q)
                          if $q;    # skip if exists but is empty
                    }
                }
                else {
                    # objects.search called outside OpenAPI context
                    # might be a hashref
                    push @query_params_array,
                      $json->decode( $reserved_params->{q} )
                      if $reserved_params->{q};
                }

                push @query_params_array,
                  $json->decode( $reserved_params->{'x-koha-query'} )
                  if defined $reserved_params->{'x-koha-query'};

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

            # Perform search
            my $objects = $result_set->search( $filtered_params, $attributes );
            my $total   = $result_set->search->count;

            $c->add_pagination_headers(
                {
                    total => (
                          $objects->is_paged
                        ? $objects->pager->total_entries
                        : $objects->count
                    ),
                    base_total => $total,
                    params     => $args,
                }
            );

            return $objects;
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
