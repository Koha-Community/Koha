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
use Data::Dumper qw(Dumper);

use C4::Context qw(preference);
use C4::Log;

use Koha::DateUtils qw(dt_from_string);
use Koha::Patrons;
use Koha::Biblios;
use Koha::Items;
use Koha::Libraries;

use base qw(Koha::Object);

=head1 NAME

Koha::Hold - Koha Hold object class

=head1 API

=head2 Class Methods

=cut

=head3 suspend_hold

my $hold = $hold->suspend_hold( $suspend_until_dt );

=cut

sub suspend_hold {
    my ( $self, $dt ) = @_;

    $dt = $dt ? $dt->clone()->truncate( to => 'day' ) : undef;

    if ( $self->is_waiting ) {    # We can't suspend waiting holds
        carp "Unable to suspend waiting hold!";
        return $self;
    }

    $self->suspend(1);
    $self->suspend_until( $dt );

    $self->store();

    logaction( 'HOLDS', 'SUSPEND', $self->reserve_id, Dumper($self->unblessed) )
        if C4::Context->preference('HoldsLog');

    return $self;
}

=head3 resume

my $hold = $hold->resume();

=cut

sub resume {
    my ( $self ) = @_;

    $self->suspend(0);
    $self->suspend_until( undef );

    $self->store();

    logaction( 'HOLDS', 'RESUME', $self->reserve_id, Dumper($self->unblessed) )
        if C4::Context->preference('HoldsLog');

    return $self;
}

=head3 delete

$hold->delete();

=cut

sub delete {
    my ( $self ) = @_;

    my $deleted = $self->SUPER::delete($self);

    logaction( 'HOLDS', 'DELETE', $self->reserve_id, Dumper($self->unblessed) )
        if C4::Context->preference('HoldsLog');

    return $deleted;
}

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

=head3 is_found

Returns true if hold is a waiting or in transit

=cut

sub is_found {
    my ($self) = @_;

    return 0 unless $self->found();
    return 1 if $self->found() eq 'W';
    return 1 if $self->found() eq 'T';
}

=head3 is_waiting

Returns true if hold is a waiting hold

=cut

sub is_waiting {
    my ($self) = @_;

    my $found = $self->found;
    return $found && $found eq 'W';
}

=head3 is_in_transit

Returns true if hold is a in_transit hold

=cut

sub is_in_transit {
    my ($self) = @_;

    return 0 unless $self->found();
    return $self->found() eq 'T';
}

=head3 is_cancelable

Returns true if hold is a cancelable hold

Holds may be canceled if they not found, or
are found and waiting. A hold found but in
transit cannot be canceled.

=cut

sub is_cancelable {
    my ($self) = @_;

    return 1 unless $self->is_found();
    return 0 if $self->is_in_transit();
    return 1 if $self->is_waiting();
    return 0;
}

=head3 is_at_destination

Returns true if hold is waiting
and the hold's pickup branch matches
the hold item's holding branch

=cut

sub is_at_destination {
    my ($self) = @_;

    return $self->is_waiting() && ( $self->branchcode() eq $self->item()->holdingbranch() );
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

Returns the related Koha::Library object for this Hold

=cut

sub branch {
    my ($self) = @_;

    $self->{_branch} ||= Koha::Libraries->find( $self->branchcode() );

    return $self->{_branch};
}

=head3 borrower

Returns the related Koha::Patron object for this Hold

=cut

sub borrower {
    my ($self) = @_;

    $self->{_borrower} ||= Koha::Patrons->find( $self->borrowernumber() );

    return $self->{_borrower};
}

=head3 is_suspended

my $bool = $hold->is_suspended();

=cut

sub is_suspended {
    my ( $self ) = @_;

    return $self->suspend();
}

=head3 type

=cut

sub _type {
    return 'Reserve';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
