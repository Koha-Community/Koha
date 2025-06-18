package Koha::Exceptions::Preservation;

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

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Preservation' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Preservation::MissingSettings' => {
        isa         => 'Koha::Exceptions::Preservation',
        description => "Missing configuration settings",
        fields      => ['parameter'],
    },
    'Koha::Exceptions::Preservation::ItemAlreadyInTrain' => {
        isa         => 'Koha::Exceptions::Preservation',
        description => "Cannot add item to waiting list, it is already in a non-received train",
    },
    'Koha::Exceptions::Preservation::ItemAlreadyInAnotherTrain' => {
        isa         => 'Koha::Exceptions::Preservation',
        description => "Cannot add item to this train, it is already in an other non-received train",
        fields      => ['train_id'],
    },
    'Koha::Exceptions::Preservation::ItemNotInWaitingList' => {
        isa         => 'Koha::Exceptions::Preservation',
        description => "Cannot add item to train, it is not in the waiting list",
    },
    'Koha::Exceptions::Preservation::ItemNotFound' => {
        isa         => 'Koha::Exceptions::Preservation',
        description => "Cannot add item to train, the item does not exist",
    },
    'Koha::Exceptions::Preservation::CannotAddItemToClosedTrain' => {
        isa         => 'Koha::Exceptions::Preservation',
        description => "Cannot add item to a closed train",
    },

);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ($msg) {
        if ( $self->isa('Koha::Exceptions::Preservation::MissingSettings') ) {
            $msg = sprintf( "The following parameter settings is required: %s", $self->parameter );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Preservation - Exception class for the preservation module

=head1 Exceptions

=head2 Koha::Exceptions::Preservation

Generic Preservation exception

=head2 Koha::Exceptions::Preservation::MissingSettings

Exception to be used when the preservation module is not configured correctly
and a setting is missing

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
