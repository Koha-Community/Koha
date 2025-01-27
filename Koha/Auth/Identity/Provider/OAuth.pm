package Koha::Auth::Identity::Provider::OAuth;

# Copyright Theke Solutions 2022
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

use base qw(Koha::Auth::Identity::Provider);

=head1 NAME

Koha::Auth::Identity::Provider::OAuth - Koha Auth Provider Object class

=head1 API

=head2 Class methods

=head3 new

    my $oauth = Koha::Auth::Identity::Provider::OAuth->new( \%{params} );

Overloaded class to create a new OAuth provider.

=cut

sub new {
    my ( $class, $params ) = @_;

    $params->{protocol} = 'OAuth';

    return $class->SUPER::new($params);
}

=head2 Internal methods

=head3 mandatory_config_attributes

Returns a list of the mandatory config entries for the protocol.

=cut

sub mandatory_config_attributes {
    return qw(
        key
        secret
        authorize_url
        token_url
    );
}

1;
