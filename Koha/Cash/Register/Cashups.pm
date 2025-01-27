package Koha::Cash::Register::Cashups;

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

use Koha::Database;
use Koha::Cash::Register::Cashup;

use base qw(Koha::Cash::Register::Actions);

=head1 NAME

Koha::Cash::Register::Actions - Koha Cash Register Action Object set class

=head1 API

=head2 Class methods

=head3 search

    my $cashups = Koha::Cash::Register::Cashups->search( $where, $attr );

Returns a list of cash register cashups.

=cut

sub search {
    my ( $self, $where, $attr ) = @_;

    unless ( exists $attr->{order_by} ) {
        $attr->{order_by} =
            [ { '-asc' => 'register_id' }, { '-desc' => 'timestamp' } ];
    }

    my $rs = $self->SUPER::search( { code => 'CASHUP' } );
    return $rs->SUPER::search( $where, $attr );
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Cash::Register::Cashup';
}

1;
