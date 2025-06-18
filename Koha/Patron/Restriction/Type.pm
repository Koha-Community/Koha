package Koha::Patron::Restriction::Type;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::Object);

use Koha::Exceptions;

use Koha::Patron::Restriction::Types;
use C4::Context;

=head1 NAME

Koha::Patron::Restriction::Type - Koha RestrictionType Object class

=head1 API

=head2 Class methods

=head3 delete

Overloaded delete method that does extra clean up:
- Reset all restrictions using the restriction type about to be deleted
  back to whichever restriction is marked as default

=cut

sub delete {
    my ($self) = @_;

    # Ensure we can't delete the current default
    Koha::Exceptions::CannotDeleteDefault->throw if $self->is_default;

    # Ensure we can't delete system values
    Koha::Exceptions::CannotDeleteSystem->throw if $self->is_system;

    return $self->_result->result_source->schema->txn_do(
        sub {
            # Update all linked restrictions to the default
            my $default = Koha::Patron::Restriction::Types->find( { is_default => 1 } )->code;

            # We can't use Koha objects here because Koha::Patron::Debarments
            # is not a Koha object. So we'll do it old skool
            my $rows = C4::Context->dbh->do(
                "UPDATE borrower_debarments SET type = ? WHERE type = ?",
                undef, ( $default, $self->code )
            );

            return $self->SUPER::delete;
        }
    );
}

=head3 make_default

Set the current restriction type as the default for manual restrictions

=cut

sub make_default {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            my $types =
                Koha::Patron::Restriction::Types->search( { code => { '!=' => $self->code } } );
            $types->update( { is_default => 0 } );
            $self->set( { is_default => 1 } );
            $self->SUPER::store;
        }
    );

    return $self;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'RestrictionType';
}

1;
