package Koha::Hold;

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

use C4::Context qw(preference);
use Koha::Branches;
use Koha::Biblios;
use Koha::Items;
use Koha::DateUtils qw(dt_from_string);

use base qw(Koha::Object);

=head1 NAME

Koha::Hold - Koha Hold object class

=head1 API

=head2 Class Methods

=cut

=head3 waiting_expires_on

Returns a DateTime for the date a waiting holds expires on.
Returns undef if the system peference ReservesMaxPickUpDelay is not set.
Returns undef if the hold is not waiting ( found = 'W' ).

=cut

sub waiting_expires_on {
    my ($self) = @_;

    my $found = $self->found;
    return unless $found && $found eq 'W';

    my $ReservesMaxPickUpDelay = C4::Context->preference('ReservesMaxPickUpDelay');
    return unless $ReservesMaxPickUpDelay;

    my $dt = dt_from_string( $self->waitingdate() );

    $dt->add( days => $ReservesMaxPickUpDelay );

    return $dt;
}

=head3 is_waiting

Returns true if hold is a waiting hold

=cut

sub is_waiting {
    my ($self) = @_;

    my $found = $self->found;
    return $found && $found eq 'W';
}

=head3 biblio

Returns the related Koha::Biblio object for this hold

=cut

sub biblio {
    my ($self) = @_;

    $self->{_biblio} ||= Koha::Biblios->find( $self->biblionumber() );

    return $self->{_biblio};
}

=head3 item

Returns the related Koha::Item object for this Hold

=cut

sub item {
    my ($self) = @_;

    $self->{_item} ||= Koha::Items->find( $self->itemnumber() );

    return $self->{_item};
}

=head3 branch

Returns the related Koha::Branch object for this Hold

=cut

sub branch {
    my ($self) = @_;

    $self->{_branch} ||= Koha::Branches->find( $self->branchcode() );

    return $self->{_branch};
}

=head3 type

=cut

sub type {
    return 'Reserve';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
