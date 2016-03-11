package Koha::Acquisition::Currency;

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

Koha::Acquisition::Currency - Koha Acquisition Currency Object class

=head1 API

=head2 Class Methods

=cut

=head3 store

=cut

sub store {
    my ( $self ) = @_;
    my $result;
    $self->_result->result_source->schema->txn_do( sub {
        if ( $self->active ) {
            # Remove the active flag from all other active currencies
            my @currencies = Koha::Acquisition::Currencies->search(
                {
                    currency => { '!=' => $self->currency },
                    active => 1,
                }
            );
            for my $currency ( @currencies ) {
                $currency->active(0);
                $currency->store;
            }
        }
        $result = $self->SUPER::store;
    });
    return $result;
}

=head3 _type

=cut

sub _type {
    return 'Currency';
}

1;
