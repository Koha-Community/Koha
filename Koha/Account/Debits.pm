package Koha::Account::Debits;

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
use Koha::Account::Debit;

use base qw(Koha::Account::Lines);

=head1 NAME

Koha::Account::Debits - Koha Cash Register Action Object set class

=head1 API

=head2 Class methods

=head3 search

  my $debits = Koha::Account::Debits->search( $where, $attr );

Returns a list of debit lines.

=cut

sub search {
    my ( $self, $where, $attr ) = @_;

    my $rs = $self->SUPER::search({ credit_type_code => undef });
    return $rs->SUPER::search( $where, $attr );
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Account::Debit';
}

1;
