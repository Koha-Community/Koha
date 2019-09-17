package Koha::Cash::Register;

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

=encoding utf8

=head1 NAME

Koha::Cash::Register - Koha cashregister Object class

=head1 API

=head2 Class methods

=cut

=head3 library

Return the library linked to this cash register

=cut

sub library {
    my ($self) = @_;
    my $rs = $self->_result->branch;
    return unless $rs;
    return Koha::Library->_new_from_dbic($rs);
}

=head3 store

Local store method to prevent direct manipulation of the 'branch_default' field

=cut

sub store {
    my ($self) = @_;
    $self->_result->result_source->schema->txn_do(
        sub {
            if ( $self->_result->is_column_changed('branch_default') ) {
                Koha::Exceptions::Object::ReadOnlyProperty->throw(
                    property => 'branch_default' );
            }
            else {
                if ($self->_result->is_column_changed('branch') && $self->branch_default) {
                }
                $self = $self->SUPER::store;
            }
        }
    );
    return $self;
}

=head3 make_default

Set the current cash register as the branch default

=cut

sub make_default {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            my $registers =
              Koha::Cash::Registers->search( { branch => $self->branch } );
            $registers->update( { branch_default => 0 } );
            $self->set( { branch_default => 1 } );
            $self->SUPER::store;
        }
    );

    return $self;
}

=head3 drop_default

Drop the current cash register as the branch default

=cut

sub drop_default {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            $self->set( { branch_default => 0 } );
            $self->SUPER::store;
        }
    );

    return $self;
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'CashRegister';
}

1;

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
