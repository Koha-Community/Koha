package Koha::Acquisition::Order;

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

use Carp qw( croak );

use Koha::Acquisition::Baskets;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

use base qw(Koha::Object);

=head1 NAME

Koha::Acquisition::Order Object class

=head1 API

=head2 Class methods

=head3 new

Overloaded I<new> method for backwards compatibility.

=cut

sub new {
    my ( $self, $params ) = @_;

    my $schema  = Koha::Database->new->schema;
    my @columns = $schema->source('Aqorder')->columns;

    my $values =
      { map { exists $params->{$_} ? ( $_ => $params->{$_} ) : () } @columns };
    return $self->SUPER::new($values);
}

=head3 store

Overloaded I<store> method for backwards compatibility.

=cut

sub store {
    my ($self) = @_;

    my $schema  = Koha::Database->new->schema;
    # Override quantity for standing orders
    $self->quantity(1) if ( $self->basketno && $schema->resultset('Aqbasket')->find( $self->basketno )->is_standing );

    # if these parameters are missing, we can't continue
    for my $key (qw( basketno quantity biblionumber budget_id )) {
        croak "Cannot insert order: Mandatory parameter $key is missing"
          unless $self->$key;
    }

    $self->quantityreceived(0) unless $self->quantityreceived;
    $self->entrydate(dt_from_string) unless $self->entrydate;

    $self->ordernumber(undef) unless $self->ordernumber;
    $self = $self->SUPER::store( $self );

    unless ( $self->parent_ordernumber ) {
        $self->set( { parent_ordernumber => $self->ordernumber } );
        $self = $self->SUPER::store( $self );
    }

    return $self;
}

=head3 add_item

  $order->add_item( $itemnumber );

Link an item to this order.

=cut

sub add_item {
    my ( $self, $itemnumber )  = @_;

    my $schema = Koha::Database->new->schema;
    my $rs = $schema->resultset('AqordersItem');
    $rs->create({ ordernumber => $self->ordernumber, itemnumber => $itemnumber });
}

=head3 basket

    my $basket = Koha::Acquisition::Orders->find( $id )->basket;

Returns the basket associated to the order.

=cut

sub basket {
    my ( $self )  = @_;
    my $basket_rs = $self->_result->basketno;
    return Koha::Acquisition::Basket->_new_from_dbic( $basket_rs );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqorder';
}

1;
