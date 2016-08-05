package Koha::Patron::Modification;

# Copyright ByWater Solutions 2014
#
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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Modification - Class represents a request to modify or create a patron

=head2 Class Methods

=cut

=head2 approve

$m->approve();

Commits the pending modifications to the borrower record and removes
them from the modifications table.

=cut

sub approve {
    my ($self) = @_;

    my $data = $self->unblessed();

    delete $data->{timestamp};
    delete $data->{verification_token};

    foreach my $key ( keys %$data ) {
        delete $data->{$key} unless ( defined( $data->{$key} ) );
    }

    my $patron = Koha::Patrons->find( $self->borrowernumber );

    return unless $patron;

    $patron->set($data);

    if ( $patron->store() ) {
        return $self->delete();
    }
}

=head3 type

=cut

sub _type {
    return 'BorrowerModification';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
