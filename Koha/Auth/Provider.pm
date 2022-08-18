package Koha::Auth::Provider;

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

use base qw(Koha::Object);

use Koha::Auth::Provider::Domains;

=head1 NAME

Koha::Auth::Provider - Koha Auth Provider Object class

=head1 API

=head2 Class methods

=head3 domains

    my $domains = $provider->domains;

Returns the related I<Koha::Auth::Provider::Domains> iterator.

=cut

sub domains {
    my ($self) = @_;

    return Koha::Auth::Provider::Domains->_new_from_dbic( scalar $self->_result->domains );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'AuthProvider';
}

1;
