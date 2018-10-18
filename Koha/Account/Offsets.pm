package Koha::Account::Offsets;

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

use Carp;
use List::Util qw(sum0);

use Koha::Database;

use Koha::Account::Offset;

use base qw(Koha::Objects);

=head1 NAME

Koha::Account::Offsets - Koha Account Offset Object set class

Account offsets track the changes made to the balance of account lines

=head1 API

=head2 Class methods

=head3 total

=cut

sub total {
    my ( $self ) = @_;

    my $total = sum0( $self->get_column('amount') );

    return $total;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'AccountOffset';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Account::Offset';
}

1;
