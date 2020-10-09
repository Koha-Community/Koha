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

=head3 objects.search

    my $patrons_rs = Koha::Patrons->new;
    my $patrons = $c->objects->search( $patrons_rs );

Performs a database search using given Koha::Objects object and query parameters.

Returns an arrayref of the hashrefs representing the resulting objects
for API rendering.

=cut

sub register {
    my ( $self, $app ) = @_;

    $app->helper(
        'objects.find' => sub {
            my ( $c, $result_set, $id ) = @_;

            my $attributes = {};

            # Look for embeds
            my $embed = $c->stash('koha.embed');
            # Generate prefetches for embedded stuff
            $c->dbic_merge_prefetch(
                {
                    attributes => $attributes,
                    result_set => $result_set
                }
            );

            my $object = $result_set->find( $id, $attributes );

            return $object->to_api({ embed => $embed });
        }
    );

    $app->helper(
        'objects.search' => sub {
            my ( $c, $result_set ) = @_;

            my $args = $c->validation->output;
            my $attributes = {};

            # Extract reserved params
            my ( $filtered_params, $reserved_params, $path_params ) = $c->extract_reserved_params($args);
            # Look for embeds
            my $embed = $c->stash('koha.embed');

            # Merge sorting into query attributes
            $c->dbic_merge_sorting(
                {
                    attributes => $attributes,
                    params     => $reserved_params,
                    result_set => $result_set
                }
            );

            # If no pagination parameters are passed, default
            $reserved_params->{_per_page} //= C4::Context->preference('RESTdefaultPageSize');
            $reserved_params->{_page}     //= 1;

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
                $filtered_params = $result_set->attributes_from_api($filtered_params);
                $filtered_params = $c->build_query_params( $filtered_params, $reserved_params );
            }

            if( defined $reserved_params->{q} || defined $reserved_params->{query} || defined $reserved_params->{'x-koha-query'}) {
                $filtered_params //={};
                my @query_params_array;
                my $query_params;
                push @query_params_array, $reserved_params->{query} if defined $reserved_params->{query};
                my $json = JSON->new;
                push @query_params_array, $json->decode($reserved_params->{q}) if defined $reserved_params->{q};
                push @query_params_array, $json->decode($reserved_params->{'x-koha-query'}) if defined $reserved_params->{'x-koha-query'};

                if(scalar(@query_params_array) > 1) {
                    $query_params = {'-and' => \@query_params_array};
                } else {
                    $query_params = $query_params_array[0];
                }

                $filtered_params = $c->merge_q_params( $filtered_params, $query_params, $result_set );
            }
            # Perform search
            my $objects = $result_set->search( $filtered_params, $attributes );
            my $total   = $result_set->search->count;

            $c->add_pagination_headers(
                {
                    total      => ($objects->is_paged ? $objects->pager->total_entries : $objects->count),
                    base_total => $total,
                    params     => $args,
                }
            );

            return $objects->to_api({ embed => $embed });
        }
    );
}

1;
