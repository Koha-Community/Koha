package Koha::Exceptions::Metadata;

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

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Metadata' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Metadata::Invalid' => {
        isa         => 'Koha::Exceptions::Metadata',
        description => 'Invalid data',
        fields      => [ 'id', 'biblionumber', 'format', 'schema', 'decoding_error' ]
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ($msg) {
        if ( $self->isa('Koha::Exceptions::Metadata::Invalid') ) {
            $msg = sprintf(
                "Invalid data, cannot decode metadata object (biblio_metadata.id=%s, biblionumber=%s, format=%s, schema=%s, decoding_error='%s')",
                $self->id, $self->biblionumber, $self->format, $self->schema, $self->decoding_error
            );
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
