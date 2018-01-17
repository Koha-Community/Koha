package Koha::REST::Plugin::Objects;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Plugin';

=head1 NAME

Koha::REST::Plugin::Objects

=head1 API

=head2 Helper methods

=head3 objects.search

    my $patrons_set = Koha::Patrons->new;
    my $patrons = $c->objects->search( $patrons_set, [\&to_model, \&to_api] );

Performs a database search using given Koha::Objects object and query parameters.
It (optionally) applies the I<$to_model> function reference before building the
query itself, and (optionally) applies I<$to_api> to the result.

Returns an arrayref of the hashrefs representing the resulting objects
for JSON rendering.

Note: Make sure I<$to_model> and I<$to_api> don't autovivify keys.

=cut

sub register {
    my ( $self, $app ) = @_;

    $app->helper(
        'objects.search' => sub {
            my ( $c, $objects_set, $to_model, $to_api ) = @_;

            my $args = $c->validation->output;
            my $attributes = {};

            # Extract reserved params
            my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($args);

            # Merge sorting into query attributes
            $c->dbic_merge_sorting(
                {
                    attributes => $attributes,
                    params     => $reserved_params
                }
            );

            # Merge pagination into query attributes
            $c->dbic_merge_pagination(
                {
                    filter => $attributes,
                    params => $reserved_params
                }
            );

            # Call the to_model function by reference, if defined
            if ( defined $filtered_params ) {

                # Apply the mapping function to the passed params
                $filtered_params = $to_model->($filtered_params)
                  if defined $to_model;
                $filtered_params = $c->build_query_params( $filtered_params, $reserved_params );
            }

            # Perform search
            my $objects = $objects_set->search( $filtered_params, $attributes );

            if ($objects->is_paged) {
                $c->add_pagination_headers({
                    total => $objects->pager->total_entries,
                    params => $args,
                });
            }

            my @objects_list = map {
                ( defined $to_api )
                  ? $to_api->( $_->TO_JSON )
                  : $_->TO_JSON
            } $objects->as_list;

            return \@objects_list;
        }
    );
}

1;
