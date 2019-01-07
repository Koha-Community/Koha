package Koha::Availability;

# Copyright Koha-Suomi Oy 2016
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

use Koha::DateUtils;

use Koha::Exceptions;

=head1 NAME

Koha::Availability - Koha Availability object class

=head1 SYNOPSIS

Class for storing availability information.

=head1 DESCRIPTION

A class to contain availability information in an uniform way.

Koha::Availability has no actual availability calculation logic, but simply
methods to get and set availability information into the object. To get actual
availability responses for items/biblios, use e.g. Koha::Availability::Hold.

Koha::Availability can represent four levels of availability statuses:
1. available
2. available, with an additional note
3. available, but requires confirmation
4. unavailable

Additional notes, reasons for a need to confirm and reasons for unavailabilities
are kept in a HASHref, where each value in my proposal is a Koha::Exceptions::*.
This allows us to easily store any additional data directly into the reason. For
example, if we want to check biblio availability for hold and find out it is not
available, the HASHref for unavailabilities has a Koha::Exceptions::Patron::Debt
that contains parameters "current_outstanding" and "max_outstanding" which lets
us pick up the information easily later on without making new queries.

With such design, Koha::Availability will be used as a parent for different types
of availabilities, like hold and checkout availability. This allows each type of
availability to perform uniformly; the ways to find out availability will be the
same and the problems with availability are represented the same way.

Example of inheritance described above:

       Koha::Availability::Hold          Koha::Availability::Checkout
                  |                                   |
                   \_________________________________/
                                   |
                          Koha::Availability

=head2 Class Methods

=cut

=head3 new

Creates a new Koha::Availability object.

=cut

sub new {
    my ($class, $params) = @_;

    my $self = {
        available                       => 1,     # boolean value yes / no
        confirmations                   => {},    # needs confirmation reasons
        notes                           => {},    # availability notes
        unavailabilities                => {},    # unavailability reasons
        expected_available              => undef, # expected availability date
    };

    bless $self, $class;

    return $self;
}

sub AUTOLOAD {
    my ($self, $params) = @_;

    my $method = our $AUTOLOAD;
    $method =~ s/.*://;

    # Accessor for class parameters
    if (exists $self->{$method}) {
        unless (defined $params) {
            return $self->{$method};
        } else {
            $self->{$method} = $params;
            return $self;
        }
    } elsif ($self->can($method)) {
        $self->$method($params);
    } else {
        Koha::Exceptions::Object::MethodNotFound->throw(
            "No method $method for " . ref($self)
        );
    }
}

sub DESTROY { }

=head3 confirm

Get: $availability->confirm
    Returns count of reasons that require confirmation.
    To get each reason, use accessor $availability->confirmations.

Set: $availability->confirm(Koha::Exceptions::Item::Damaged->new)
    Maintains the availability status as available, and adds the given reason
    into $availability->confirmations.

=cut

sub confirm {
    my ($self, $status) = @_;

    if (!$status) {
        my $keys = keys %{$self->{confirmations}};
        return $keys ? $keys : 0;
    } else {
        if (!keys %{$self->{unavailabilities}}) {
            $self->{available} = 1;
        }
        my $key = ref($status);
        $self->{confirmations}->{$key} = $status;
    }
}

=head3 note

Get: $availability->note
    Returns count of additional notes.
    To get each reason, use accessor $availability->notes.

Set: $availability->note(Koha::Exceptions::Item::Lost->new)
    If no unavailability reasons are stored, sets availability true, and adds
    given object as additional availability note. Otherwise does nothing.

=cut

sub note {
    my ($self, $status) = @_;

    if (!$status) {
        my $keys = keys %{$self->{notes}};
        return $keys ? $keys : 0;
    } else {
        if (!keys %{$self->{unavailabilities}}) {
            $self->{available} = 1;
        }
        my $key = ref($status);
        $self->{notes}->{$key} = $status;
    }
}

=head3 reset

$availability->reset

Resets availability status to available and cleans the object from any existing
notes, confirmations and unavailabilities.

=cut

sub reset {
    my ($self) = @_;

    $self->{'available'} = 1;
    $self->{'confirmations'} = {};
    $self->{'notes'} = {};
    $self->{'unavailabilities'} = {};

    return $self;
}

=head3 unavailable

Accessor for unavailability.

Get: $availability->unavailable
    Returns count of reasons that make availability false.
    To get all reasons, use accessor $availability->unavailabilities.

Set: $availability->unavailable(Koha::Exceptions::Item::Withdrawn->new)
    Sets availability status as "unavailable" and stores the given reason.

=cut

sub unavailable {
    my ($self, $status) = @_;

    if (!$status) {
        my $keys = keys %{$self->{unavailabilities}};
        return $keys ? $keys : 0;
    } else {
        $self->{available} = 0;
        my $key = ref($status);
        $self->{unavailabilities}->{$key} = $status;
    }
}


sub _swaggerize_exception {
    my ($self, $exceptions) = @_;

    my $ret = {};
    foreach my $ex (keys %{$exceptions}) {
        my $name = $ex;
        $name =~ s/Koha::Exceptions:://;
        $ret->{$name} = {};
        foreach my $field ($exceptions->{$ex}->Fields) {
            my $val = $exceptions->{$ex}->$field;
            last unless $val;
            if ($val =~ /^(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})/) {
                eval {
                    $val = dt_from_string($val, 'sql')->strftime('%FT%T%z');
                    #RFC3339 time-numoffset: ("+" / "-") time-hour ":" time-minute
                    substr($val, -2, 0, ':');
                };
            }
            $ret->{$name}->{$field} = $val;
        }
    }
    return $ret;
}

1;
