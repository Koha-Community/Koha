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

use Modern::Perl;

use Mojo::Base 'Mojolicious::Plugin';

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
}

=head2 Internal methods

=head3 _reserved_words

    my $reserved_words = _reserved_words();

=cut

sub _reserved_words {

    my @reserved_words = qw( _match _order_by _page _per_page );
    return \@reserved_words;
}

1;
