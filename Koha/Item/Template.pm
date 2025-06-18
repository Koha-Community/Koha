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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use JSON;

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
        $self->contents( $self->_json->encode( $self->contents ) );
    }

    $self = $self->SUPER::store;
}

=head3 decoded_contents

Returns a deserilized perl structure of the JSON formatted contents

=cut

sub decoded_contents {
    my ($self) = @_;

    return $self->_json->decode( $self->contents ) if $self->contents;
}

=head2 Internal methods

=head3 _json

=cut

sub _json {
    my $self = shift;
    $self->{_json} //= JSON->new;    # Keep utf8 off !
}

=head3 _type

=cut

sub _type {
    return 'ItemEditorTemplate';
}

1;
