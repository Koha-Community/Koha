package Koha::Acquisition::Orders;

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

use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Order;
use Koha::Exception;

use base qw(Koha::Objects);

=head1 NAME

Koha::Acquisition::Orders object set class

=head1 API

=head2 Class methods

=head3 filter_by_lates

my $late_orders = $orders->filter_by_lates($params);

Filter an order set given different parameters.

This is the equivalent method of the former GetLateOrders C4 subroutine

$params can be:

=over

=item C<delay> the number of days the basket has been closed

=item C<bookseller_id> the bookseller id

=item C<estimated_from> Beginning of the estimated delivery date

=item C<estimated_to> End of the estimated delivery date

=back

=cut

sub filter_by_lates {
    my ( $self, $params ) = @_;
    my $delay = $params->{delay};
    my $bookseller_id = $params->{bookseller_id};
    # my $branchcode = $params->{branchcode}; # FIXME do we really need this
    my $estimated_from = $params->{estimated_from};
    my $estimated_to = $params->{estimated_to};
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    my @delivery_time_conditions;
    my $date_add = "DATE_ADD(basketno.closedate, INTERVAL COALESCE(booksellerid.deliverytime, booksellerid.deliverytime, 0) day)";
    my @estimated_delivery_time_conditions;
    if ( defined $estimated_from or defined $estimated_to ) {
        push @delivery_time_conditions, \[ "$date_add IS NOT NULL" ];
        push @delivery_time_conditions, \[ "estimated_delivery_date IS NULL" ];
        push @estimated_delivery_time_conditions, \[ "estimated_delivery_date IS NOT NULL" ];
    }
    if ( defined $estimated_from ) {
        push @delivery_time_conditions, \[ "$date_add >= ?", $dtf->format_date($estimated_from) ];
        push @estimated_delivery_time_conditions, \[ "estimated_delivery_date >= ?", $dtf->format_date($estimated_from) ];
    }
    if ( defined $estimated_to ) {
        push @delivery_time_conditions, \[ "$date_add <= ?", $dtf->format_date($estimated_to) ];
        push @estimated_delivery_time_conditions, \[ "estimated_delivery_date <= ?", $dtf->format_date($estimated_to) ];
    }
    if ( defined $estimated_from and not defined $estimated_to ) {
        push @delivery_time_conditions, \[ "$date_add <= ?", $dtf->format_date(dt_from_string) ];
        push @estimated_delivery_time_conditions, \[ "estimated_delivery_date <= ?", $dtf->format_date(dt_from_string) ];
    }

    $self->search(
        {
            -or => [
                { datereceived => undef },
                quantityreceived => { '<' => \'quantity' }
            ],
            'basketno.closedate' => [
                -and =>
                { '!=' => undef },
                {
                    defined $delay
                    ? (
                        '<=' => $dtf->format_date(
                            dt_from_string->subtract( days => $delay )
                        )
                      )
                    : ()
                }
              ],
            'datecancellationprinted' => undef,
            (
                $bookseller_id
                ? ( 'basketno.booksellerid' => $bookseller_id )
                : ()
            ),

            # ( $branchcode ? ('borrower.branchcode')) # FIXME branch is not a filter we may not need to implement this

            ( ( @delivery_time_conditions and @estimated_delivery_time_conditions ) ?
                ( -or =>
                    [
                        -and => \@estimated_delivery_time_conditions,
                        -and => \@delivery_time_conditions
                    ]
                )
                : ()
            ),
            (
                C4::Context->preference('IndependentBranches')
                  && !C4::Context->IsSuperLibrarian
                ? ( 'borrower.branchcode' => C4::Context->userenv->{branch} )
                : ()
            ),

            ( orderstatus => { '-not_in' => ['cancelled', 'complete'] } ),

        },
        {
            '+select' => [
                \"DATE_ADD(basketno.closedate, INTERVAL COALESCE(booksellerid.deliverytime, booksellerid.deliverytime, 0) day)",
            ],
            '+as' => [qw/
                calculated_estimated_delivery_date
            /],
            join => { 'basketno' => 'booksellerid' },
            prefetch => {'basketno' => 'booksellerid'},
        }
    );
}

=head3 filter_by_active

    my $new_rs = $orders->filter_by_active;

Returns a new resultset filtering orders that are not active.

=cut

sub filter_by_active {
    my ($self) = @_;
    return $self->search(
        {
            '-or' => [
                { 'basket.is_standing' => 1,
                  'orderstatus' => [ 'new', 'ordered', 'partial' ] },
                { 'orderstatus' => [ 'ordered', 'partial' ] }
            ]
        },
        { join => 'basket' }
    );
}

=head3 filter_by_current

    $orders->filter_by_current

Return the orders of the set that have not been cancelled.

=cut

sub filter_by_current {
    my ($self) = @_;
    return $self->search(
        {
            datecancellationprinted => undef,
        }
    );
}

=head3 filter_by_cancelled

    $orders->filter_by_cancelled

Return the orders of the set that have been cancelled.

=cut

sub filter_by_cancelled {
    my ($self) = @_;
    return $self->search(
        {
            datecancellationprinted => { '!=' => undef }
        }
    );
}

=head3 filter_by_id_including_transfers

    my $orders = $orders->filter_by_id_including_transfers(
        {
            ordernumber => $ordernumber
        }
    );

When searching for orders by I<ordernumber>, include the aqorders_transfers table
so we can find orders that have changed their ordernumber as the result of a transfer

=cut

sub filter_by_id_including_transfers {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw( "The ordernumber param is mandatory" )
        unless $params->{ordernumber};

    return $self->search(
        {
            -or => [
                { 'me.ordernumber' => $params->{ordernumber} },
                { 'aqorders_transfers_ordernumber_to.ordernumber_from' => $params->{ordernumber} }
            ]
        },
        { join => 'aqorders_transfers_ordernumber_to' }
    );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqorder';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Acquisition::Order';
}

1;
