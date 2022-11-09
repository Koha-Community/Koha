package Koha::Hold::HoldsQueueItem;

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

use Koha::Items;
use Koha::Biblios;
use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::Hold::HoldsQueueItem - Koha hold cancellation request Object class

=head1 API

=head2 Class methods

=head3 patron

=cut

sub patron {
    my ( $self ) = @_;
    my $rs = $self->_result->borrowernumber;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 biblio

=cut

sub biblio {
    my ( $self ) = @_;
    my $rs = $self->_result->biblionumber;
    return unless $rs;
    return Koha::Biblio->_new_from_dbic( $rs );
}

=head3 item

=cut

sub item {
    my ( $self ) = @_;
    my $rs = $self->_result->itemnumber;
    return unless $rs;
    return Koha::Item->_new_from_dbic( $rs );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'TmpHoldsqueue';
}

=head1 AUTHORS

Kyle Hall <kyle@bywatersolutions.com>

=cut

1;
