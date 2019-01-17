package Koha::REST::Plugin::Query;

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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Exceptions;

=head1 NAME

Koha::REST::Plugin::Query

=head1 API

=head2 Mojolicious::Plugin methods

=head3 register

=cut

sub register {
    my ( $self, $app ) = @_;

=head2 Helper methods

=head3 extract_reserved_params

    my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($params);

Generates the DBIC query from the query parameters.

=cut

    $app->helper(
        'extract_reserved_params' => sub {
            my ( $c, $params ) = @_;

            my $reserved_params;
            my $filtered_params;

            my $reserved_words = _reserved_words();

            foreach my $param ( keys %{$params} ) {
                if ( grep { $param eq $_ } @{$reserved_words} ) {
                    $reserved_params->{$param} = $params->{$param};
                }
                else {
                    $filtered_params->{$param} = $params->{$param};
                }
            }

            return ( $filtered_params, $reserved_params );
        }
    );

=head3 dbic_merge_sorting

    $attributes = $c->dbic_merge_sorting({ attributes => $attributes, params => $params });

Generates the DBIC order_by attributes based on I<$params>, and merges into I<$attributes>.

=cut

    $app->helper(
        'dbic_merge_sorting' => sub {
            my ( $c, $args ) = @_;
            my $attributes = $args->{attributes};

            if ( defined $args->{params}->{_order_by} ) {
                my @order_by = map { _build_order_atom($_) }
                               @{ $args->{params}->{_order_by} };
                $attributes->{order_by} = \@order_by;
            }

            return $attributes;
        }
    );

=head3 _build_query_params_from_api

    my $params = _build_query_params_from_api( $filtered_params, $reserved_params );

Builds the params for searching on DBIC based on the selected matching algorithm.
Valid options are I<contains>, I<starts_with>, I<ends_with> and I<exact>. Default is
I<contains>. If other value is passed, a Koha::Exceptions::WrongParameter exception
is raised.

=cut

    $app->helper(
        'build_query_params' => sub {

            my ( $c, $filtered_params, $reserved_params ) = @_;

            my $params;
            my $match = $reserved_params->{_match} // 'contains';

            foreach my $param ( keys %{$filtered_params} ) {
                if ( $match eq 'contains' ) {
                    $params->{$param} =
                      { like => '%' . $filtered_params->{$param} . '%' };
                }
                elsif ( $match eq 'starts_with' ) {
                    $params->{$param} = { like => $filtered_params->{$param} . '%' };
                }
                elsif ( $match eq 'ends_with' ) {
                    $params->{$param} = { like => '%' . $filtered_params->{$param} };
                }
                elsif ( $match eq 'exact' ) {
                    $params->{$param} = $filtered_params->{$param};
                }
                else {
                    # We should never reach here, because the OpenAPI plugin should
                    # prevent invalid params to be passed
                    Koha::Exceptions::WrongParameter->throw(
                        "Invalid value for _match param ($match)");
                }
            }

            return $params;
        }
    );
}

=head2 Internal methods

=head3 _reserved_words

    my $reserved_words = _reserved_words();

=cut

sub _reserved_words {

    my @reserved_words = qw( _match _order_by _page _per_page );
    return \@reserved_words;
}

=head3 _build_order_atom

    my $order_atom = _build_order_atom( $string );

Parses I<$string> and outputs data valid for using in SQL::Abstract order_by attribute
according to the following rules:

     string -> I<string>
    +string -> I<{ -asc => string }>
    -string -> I<{ -desc => string }>

=cut

sub _build_order_atom {
    my $string = shift;

    if ( $string =~ m/^\+/ or
         $string =~ m/^\s/ ) {
        # asc order operator present
        $string =~ s/^(\+|\s)//;
        return { -asc => $string };
    }
    elsif ( $string =~ m/^\-/ ) {
        # desc order operator present
        $string =~ s/^\-//;
        return { -desc => $string };
    }
    else {
        # no order operator present
        return $string;
    }
}

1;
