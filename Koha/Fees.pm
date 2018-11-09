package Koha::Fees;

# Copyright 2018 ByWater Solutions
#
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

use Carp qw( confess );

use Koha::Calendar;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;

=head1 NAME

Koha::Feess - Module calculating fees in Koha

=head3 new

Koha::Fees->new(
    {
        patron    => $patron,
        library   => $library,
        item      => $item,
        to_date   => $to_dt,
        [ from_date => $from_dt, ]
    }
);

=cut

sub new {
    my ( $class, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: patron")
        unless $patron;
    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: library")
        unless $library;
    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: item")
        unless $item;
    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: to_date")
        unless $to_date;

    Carp::confess("Key 'patron' is not a Koha::Patron object!")
      unless $params->{patron}->isa('Koha::Patron');
    Carp::confess("Key 'library' is not a Koha::Library object!")
      unless $params->{library}->isa('Koha::Library');
    Carp::confess("Key 'item' is not a Koha::Item object!")
      unless $params->{item}->isa('Koha::Item');
    Carp::confess("Key 'to_date' is not a DateTime object!")
      unless $params->{to_date}->isa('DateTime');

    if ( $params->{from_date} ) {
        Carp::croak("Key 'from_date' is not a DateTime object!")
          unless $params->{from_date}->isa('DateTime');
    }
    else {
        $params->{from_date} = dt_from_string();
    }

    return bless( $params, $class );
}

=head3 rental_charge_daily

    my $fee = $self->rental_charge_daily();

    This method calculates the daily rental fee for a given itemtype for a given
    period of time passed in as a pair of DateTime objects.

=cut

sub rental_charge_daily {
    my ( $self, $params ) = @_;

    my $itemtype = Koha::ItemTypes->find( $self->item->effective_itemtype );
    my $rental_charge_daily = $itemtype->rental_charge_daily;

    return undef unless $rental_charge_daily && $rental_charge_daily > 0;

    my $duration;
    if ( C4::Context->preference('finesCalendar') eq 'noFinesWhenClosed' ) {
        my $calendar = Koha::Calendar->new( branchcode => $self->library->id );
        $duration = $calendar->days_between( $self->from_date, $self->to_date );
    }
    else {
        $duration = $self->to_date->delta_days($self->from_date);
    }
    my $days = $duration->in_units('days');

    my $charge = $rental_charge_daily * $days;

    return $charge;
}

=head3 patron

my $patron = $fees->patron( $patron );

=cut

sub patron {
    my ( $self, $patron ) = @_;

    $self->{patron} = $patron if $patron && $patron->isa('Koha::Patron');

    return $self->{patron};
}

=head3 library

my $library = $fees->library( $library );

=cut

sub library {
    my ( $self, $library ) = @_;

    $self->{library} = $library if $library && $library->isa('Koha::Library');

    return $self->{library};
}

=head3 item

my $item = $fees->item( $item );

=cut

sub item {
    my ( $self, $item ) = @_;

    $self->{item} = $item if $item && $item->isa('Koha::Item');

    return $self->{item};
}

=head3 to_date

my $to_date = $fees->to_date( $to_date );

=cut

sub to_date {
    my ( $self, $to_date ) = @_;

    $self->{to_date} = $to_date if $to_date && $to_date->isa('DateTime');

    return $self->{to_date};
}

=head3 from_date

my $from_date = $fees->from_date( $from_date );

=cut

sub from_date {
    my ( $self, $from_date ) = @_;

    $self->{from_date} = $from_date if $from_date && $from_date->isa('DateTime');

    return $self->{from_date};
}

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut

1;
