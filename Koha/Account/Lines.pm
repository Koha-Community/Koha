package Koha::Account::Lines;

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
use List::Util qw( sum0 );

use Koha::Database;
use Koha::Account::Line;

use base qw(Koha::Objects);

=head1 NAME

Koha::Account::Lines - Koha Account Line Object set class

=head1 API

=head2 Class Methods

=head3 total_outstanding

    my $lines = Koha::Account::Lines->search({ ...  });
    my $total = $lines->total_outstanding;

Returns the sum of the outstanding amounts of the resultset. If the resultset is
empty it returns 0.

=cut

sub total_outstanding {
    my ( $self ) = @_;

    my $total = sum0( $self->get_column('amountoutstanding') );

    return $total;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Accountline';
}

sub object_class {
    return 'Koha::Account::Line';
}

1;
