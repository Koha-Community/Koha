package Koha::Exceptions::Metadata;

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

use Exception::Class (

    'Koha::Exceptions::Metadata' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Metadata::Invalid' => {
        isa => 'Koha::Exceptions::Metadata',
        description => 'Invalid data',
        fields => ['id','format','schema']
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ($msg) {
        if ( $self->isa('Koha::Exceptions::Metadata::Invalid') ) {
            $msg = sprintf( "Invalid data, cannot decode object (id=%s, format=%s, schema=%s)",
                $self->id, $self->format, $self->schema );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Metadata - Base class for metadata exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Metadata

Generic metadata exception

=head2 Koha::Exceptions::Metadata::Invalid

The metadata is invalid.

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
