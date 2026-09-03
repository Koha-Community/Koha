package Koha::Bookings;

# Copyright PTFS Europe 2021
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;
use Koha::Booking;
use Koha::DateUtils qw( dt_from_string );

use base qw(Koha::Objects);

=head1 NAME

Koha::Bookings - Koha Booking object set class

=head1 API

=head2 Class Methods

=head3 filter_by_active

    $bookings->filter_by_active;

Returns bookings that are still active, i.e. awaiting collection (C<new>) or
currently on loan (C<issued>).  Cancelled and completed bookings are excluded.

=cut

sub filter_by_active {
    my ($self) = @_;
    return $self->search( { status => { '-in' => [ 'new', 'issued' ] } } );
}

=head3 filter_by_overlapping

    my $overlapping = $bookings->filter_by_overlapping(
        {
            start_date => $start_date,
            end_date   => $end_date,
            lead_days  => $lead_days,
            trail_days => $trail_days,
        }
    );

Returns the bookings whose effective period overlaps the given period. Chain
with C<filter_by_active> to ignore cancelled and completed bookings.

A booking's effective period is its core period extended by the lead period
before the start date and the trail period after the end date. The given
period is expanded the same way, and as both share the same lead and trail
values the overlap condition becomes:

    existing_start <= end_date + trail_days + lead_days
    AND existing_end >= start_date - lead_days - trail_days

C<lead_days> and C<trail_days> default to 0, which reduces to a plain overlap
of the core periods.

=cut

sub filter_by_overlapping {
    my ( $self, $params ) = @_;

    my $start_date = dt_from_string( $params->{start_date} );
    my $end_date   = dt_from_string( $params->{end_date} );
    my $lead_days  = $params->{lead_days}  // 0;
    my $trail_days = $params->{trail_days} // 0;

    my $expanded_start = $start_date->clone->subtract( days => $lead_days + $trail_days );
    my $expanded_end   = $end_date->clone->add( days => $trail_days + $lead_days );

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    return $self->search(
        {
            '-or' => [
                start_date =>
                    { '-between' => [ $dtf->format_datetime($start_date), $dtf->format_datetime($expanded_end) ] },
                end_date =>
                    { '-between' => [ $dtf->format_datetime($expanded_start), $dtf->format_datetime($end_date) ] },
                {
                    start_date => { '<' => $dtf->format_datetime($start_date) },
                    end_date   => { '>' => $dtf->format_datetime($end_date) }
                }
            ]
        }
    );
}

=head2 Internal Methods

=head3 _type

=cut

sub _type {
    return 'Booking';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Booking';
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
