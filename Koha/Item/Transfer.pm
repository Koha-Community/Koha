package Koha::Item::Transfer;

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


use C4::Items qw( CartToShelf ModDateLastSeen );

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions::Item::Transfer;

use base qw(Koha::Object);

=head1 NAME

Koha::Item::Transfer - Koha Item Transfer Object class

=head1 API

=head2 Class Methods

=cut

=head3 item

  my $item = $transfer->item;

Returns the associated item for this transfer.

=cut

sub item {
    my ($self) = @_;
    my $item_rs = $self->_result->itemnumber;
    return Koha::Item->_new_from_dbic($item_rs);
}

=head3 from_library

  my $from_library = $transfer->from_library;

Returns the associated from_library for this transfer.

=cut

sub from_library {
    my ($self) = @_;
    my $from_library_rs = $self->_result->frombranch;
    return Koha::Library->_new_from_dbic($from_library_rs);
}

=head3 to_library

  my $to_library = $transfer->to_library;

Returns the associated to_library for this transfer.

=cut

sub to_library {
    my ($self) = @_;
    my $to_library_rs = $self->_result->tobranch;
    return Koha::Library->_new_from_dbic($to_library_rs);
}

=head3 transit

    $transfer->transit({ [ skip_record_index => 0|1 ] });

Set the transfer as in transit by updating the I<datesent> time.

Also, update date last seen and ensure item holdingbranch is correctly set.

An optional I<skip_record_index> parameter can be passed to avoid triggering
reindex.

=cut

sub transit {
    my ($self, $params) = @_;

    # Throw exception if item is still checked out
    Koha::Exceptions::Item::Transfer::OnLoan->throw() if ( $self->item->checkout );

    # Remove the 'shelving cart' location status if it is being used (Bug 3701)
    CartToShelf( $self->item->itemnumber )
      if $self->item->location
      && $self->item->location eq 'CART'
      && (!$self->item->permanent_location
        || $self->item->permanent_location ne 'CART' );

    # Update the transit state
    $self->set(
        {
            frombranch => $self->item->holdingbranch,
            datesent   => dt_from_string,
        }
    )->store;

    ModDateLastSeen( $self->item->itemnumber, undef, { skip_record_index => $params->{skip_record_index} } );
    return $self;

}

=head3 in_transit

Boolean returning whether the transfer is in transit or waiting

=cut

sub in_transit {
    my ($self) = @_;

    return ( defined( $self->datesent )
          && !defined( $self->datearrived )
          && !defined( $self->datecancelled ) );
}

=head3 receive

Receive the transfer by setting the datearrived time.

=cut

sub receive {
    my ($self) = @_;

    # Throw exception if item is checked out
    Koha::Exceptions::Item::Transfer::OnLoan->throw() if ($self->item->checkout);

    # Update the arrived date
    $self->set({ datearrived => dt_from_string })->store;

    ModDateLastSeen( $self->item->itemnumber );
    return $self;
}

=head3 cancel

  $transfer->cancel({ reason => $reason, [force => 1]});

Cancel the transfer by setting the datecancelled time and recording the reason.

=cut

sub cancel {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw(
        error => "The 'reason' parameter is mandatory" )
      unless defined($params->{reason});

    # Throw exception if item is in transit already
    Koha::Exceptions::Item::Transfer::InTransit->throw() if ( !$params->{force} && $self->in_transit );

    # Update the cancelled date
    $self->set(
        { datecancelled => dt_from_string, cancellation_reason => $params->{reason} } )
      ->store;

    return $self;
}

=head3 type

=cut

sub _type {
    return 'Branchtransfer';
}

1;
