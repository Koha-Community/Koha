package Koha::Item::Template;

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

use Encode qw(encode_utf8);
use JSON   qw(encode_json decode_json);

use base qw(Koha::Object);

=head1 NAME

Koha::Item::Template - Koha Item Template Object class

=head1 API

=head2 Class methods

=head3 store

Override base store method
to serialize the template contents as JSON

=cut

sub store {
    my ($self) = @_;

    if ( ref( $self->contents ) eq 'HASH' ) {
        $self->contents( encode_json( $self->contents ) );
    }

    $self = $self->SUPER::store;
}

=head3 decoded_contents

Returns a deserilized perl structure of the JSON formatted contents

=cut

sub decoded_contents {
    my ($self) = @_;

    return decode_json( encode_utf8($self->contents) ) if $self->contents;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ItemEditorTemplate';
}

1;
