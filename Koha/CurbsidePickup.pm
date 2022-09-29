package Koha::CurbsidePickup;

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

use Carp;

use Koha::Database;

use base qw(Koha::Object);

use C4::Circulation qw( CanBookBeIssued AddIssue );
use C4::Members::Messaging qw( GetMessagingPreferences );
use C4::Letters qw( GetPreparedLetter EnqueueLetter );
use Koha::Calendar;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patron;
use Koha::Library;
use Koha::CurbsidePickupIssues;
use Koha::Exceptions::CurbsidePickup;

=head1 NAME

Koha::CurbsidePickup - Koha Curbside Pickup Object class

=head1 API

=head2 Class methods

=cut

=head3 new

=cut

sub new {
    my ( $self, $params ) = @_;

    my $policy =
      Koha::CurbsidePickupPolicies->find( { branchcode => $params->{branchcode} } );

    Koha::Exceptions::CurbsidePickup::NotEnabled->throw
      unless $policy && $policy->enabled;

    my $calendar = Koha::Calendar->new( branchcode => $params->{branchcode} );
    Koha::Exceptions::CurbsidePickup::LibraryIsClosed->throw
      if $calendar->is_holiday( $params->{scheduled_pickup_datetime} );

    if ( $policy->enable_waiting_holds_only ) {
        my $patron        = Koha::Patrons->find( $params->{borrowernumber} );
        my $waiting_holds = $patron->holds->waiting->search( { branchcode => $params->{branchcode} } );

        Koha::Exceptions::CurbsidePickup::NoWaitingHolds->throw
          unless $waiting_holds->count;
    }
    my $existing_curbside_pickups = Koha::CurbsidePickups->search(
        {
            branchcode                => $params->{branchcode},
            borrowernumber            => $params->{borrowernumber},
            delivered_datetime        => undef,
        }
    )->filter_by_scheduled_today;
    Koha::Exceptions::CurbsidePickup::TooManyPickups->throw(
        branchcode     => $params->{branchcode},
        borrowernumber => $params->{borrowernumber}
    ) if $existing_curbside_pickups->count;

    my $is_valid =
      $policy->is_valid_pickup_datetime( $params->{scheduled_pickup_datetime} );
    unless ($is_valid) {
        my $error = @{ $is_valid->messages }[0]->message;
        Koha::Exceptions::CurbsidePickup::NoMatchingSlots->throw
          if $error eq 'no_matching_slots';
        Koha::Exceptions::CurbsidePickup::NoMorePickupsAvailable->throw
          if $error eq 'no_more_available';
        Koha::Exceptions->throw(
            "Error message must raise the appropriate exception");
    }

    return $self->SUPER::new($params);
}

=head3 notify_new_pickup

$pickup->notify_new_pickup

Will notify the patron that the pickup has been created.
Letter 'NEW_CURBSIDE_PICKUP will be used', and depending on 'Hold_Filled' configuration.

=cut

sub notify_new_pickup {
    my ( $self ) = @_;

    my $patron = $self->patron;

    my $library = $self->library;

    $patron->queue_notice({ letter_params => {
        module     => 'reserves',
        letter_code => 'NEW_CURBSIDE_PICKUP',
        borrowernumber => $patron->borrowernumber,
        branchcode => $self->branchcode,
        tables     => {
            'branches'  => $library->unblessed,
            'borrowers' => $patron->unblessed,
        },
        substitute => {
            curbside_pickup => $self,
        }
    }, message_name => 'Hold_Filled' });
}

=head3 checkouts

Return the checkouts linked to this pickup

=cut

sub checkouts {
    my ( $self ) = @_;

    my @pi = Koha::CurbsidePickupIssues->search({ curbside_pickup_id => $self->id })->as_list;

    my @checkouts = map { $_->checkout } @pi;
    @checkouts = grep { defined $_ } @checkouts;

    return @checkouts;
}

=head3 patron

Return the patron linked to this pickup

=cut

sub patron {
    my ( $self ) = @_;
    my $rs = $self->_result->borrowernumber;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 staged_by_staff

Return the staff member that staged this pickup

=cut

sub staged_by_staff {
    my ( $self ) = @_;
    my $rs = $self->_result->staged_by;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 library

Return the branch associated with this pickup

=cut

sub library {
    my ( $self ) = @_;
    my $rs = $self->_result->branchcode;
    return unless $rs;
    return Koha::Library->_new_from_dbic( $rs );
}

=head3 mark_as_staged

Mark the pickup as staged

=cut

sub mark_as_staged {
    my ( $self ) = @_;
    my $staged_by = C4::Context->userenv ? C4::Context->userenv->{number} : undef;
    $self->set(
        {
            staged_datetime  => dt_from_string(),
            staged_by        => $staged_by,
            arrival_datetime => undef,
        }
    )->store;
}

=head3 mark_as_unstaged

Mark the pickup as unstaged

=cut

sub mark_as_unstaged {
    my ( $self ) = @_;

    $self->set(
        {
            staged_datetime  => undef,
            staged_by        => undef,
            arrival_datetime => undef,
        }
    )->store;
}

=head3 mark_patron_has_arrived

Set the arrival time of the patron

=cut

sub mark_patron_has_arrived {
    my ( $self ) = @_;
    $self->set(
        {
            arrival_datetime => dt_from_string(),
        }
    )->store;
}

=head3 mark_as_delivered

Mark the pickup as delivered. The waiting holds will be filled.

=cut

sub mark_as_delivered {
    my ( $self ) = @_;
    my $patron          = $self->patron;
    my $holds           = $patron->holds;
    my $branchcode = C4::Context->userenv ? C4::Context->userenv->{branch} : undef;
    foreach my $hold ( $holds->as_list ) {
        if ( $hold->is_waiting && $branchcode && $hold->branchcode eq $branchcode ) {
            my ( $issuingimpossible, $needsconfirmation ) =
              C4::Circulation::CanBookBeIssued( $patron, $hold->item->barcode );

            unless ( keys %$issuingimpossible ) {
                my $issue =
                  C4::Circulation::AddIssue( $patron, $hold->item->barcode );
                if ($issue) {
                    Koha::CurbsidePickupIssue->new(
                        {
                            curbside_pickup_id => $self->id,
                            issue_id           => $issue->id,
                            reserve_id         => $hold->id,
                        }
                    )->store();
                }
                else {
                    Koha::Exceptions->throw(sprintf("Cannot checkout hold %s for patron %s: %s", $patron->id, $hold->id, join(", ", keys %$issuingimpossible)));
                }
            }
        }
    }

    my $delivered_by = C4::Context->userenv ? C4::Context->userenv->{number} : undef;
    $self->arrival_datetime(dt_from_string) unless $self->arrival_datetime;
    $self->set(
        {
            delivered_datetime => dt_from_string(),
            delivered_by       => $delivered_by,
        }
    )->store;
}

=head3 status

Return the status of the pickup, can be 'to-be-staged', 'staged-and-ready', 'patron-is-outside' or 'delivered'.

=cut

sub status {
    my ($self) = @_;
    return
        !defined $self->staged_datetime    ? 'to-be-staged'
      : !defined $self->arrival_datetime   ? 'staged-and-ready'
      : !defined $self->delivered_datetime ? 'patron-is-outside'
      :                                      'delivered';
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'CurbsidePickup';
}

1;
