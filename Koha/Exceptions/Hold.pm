package Koha::Exceptions::Hold;

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

use Koha::Exceptions::Exception;

use Exception::Class (
    'Koha::Exceptions::Hold' => {
        isa => 'Koha::Exceptions::Exception',
    },
    'Koha::Exceptions::Hold::CannotSuspendFound' => {
        isa         => 'Koha::Exceptions::Hold',
        description => "Found holds cannot be suspended",
        fields      =>  ['status']
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ( $msg) {
        if ( $self->isa('Koha::Exceptions::Hold::CannotSuspendFound') ) {
            $msg = sprintf("Found hold cannot be suspended. Status=%s", $self->status );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Hold - Base class for Hold exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Hold

Generic Hold exception

=head2 Koha::Exceptions::Hold::CannotSuspendFound

Exception to be used when suspension is requested on a found hold.

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
