package Koha::Account::Offset;

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
use Koha::Account::Line;

use base qw(Koha::Object);

=head1 NAME

Koha::Account::Offset - Koha account offset Object class

Account offsets are used to track the changes in account lines

=head1 API

=head2 Internal methods

=cut

=head3 debit

=cut

sub debit {
    my ( $self ) = @_;
    my $debit_rs = $self->_result->debit;
    return unless $debit_rs;
    return Koha::Account::Line->_new_from_dbic( $debit_rs );
}

=head3 credit

=cut

sub credit {
    my ( $self ) = @_;
    my $credit_rs = $self->_result->credit;
    return unless $credit_rs;
    return Koha::Account::Line->_new_from_dbic( $credit_rs );
}

=head3 _type

=cut

sub _type {
    return 'AccountOffset';
}

1;
