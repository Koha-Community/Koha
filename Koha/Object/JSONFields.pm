package Koha::Object::JSONFields;

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
use Try::Tiny;

use Koha::Exceptions;
use Koha::Exceptions::Object;

=head1 NAME

Koha::Object::JSONFields - Class that adds JSON field manipulation helper methods
for Koha::Object-derived classes

=head1 SYNOPSIS

    use base qw(Koha::Object Koha::Object::JSONFields);
    my $object = Koha::Object->new({ property1 => $property1, property2 => $property2, etc... } );
    my $field_name_hashref = $object->decode_json_field({ field => 'field_name' });
    $object->encode_json_field({ field => 'field_name', data => $data });

=head1 API

=head2 Class methods

=head3 decode_json_field

    my $hashref = $object->decode_json_field({ field => 'field_name' });

Returns a data structure representing the JSON-decoded value of field I<field_name>.

=cut

sub decode_json_field {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'field' )
        unless defined $params->{field};

    my $field = $params->{field};

    return try {
        $self->$field ? $self->_json->decode( $self->$field ) : undef;
    } catch {
        Koha::Exceptions::Object::BadValue->throw("Error reading JSON data: $_");
    };
}

=head3 set_encoded_json_field

    $object->set_encoded_json_field(
        {   data  => $data,
            field => 'field_name',
        }
    );

Sets a JSON string encoded representation of I<$data> into the object's I<field_name>
attribute.

=cut

sub set_encoded_json_field {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'field' )
        unless defined $params->{field};

    Koha::Exceptions::MissingParameter->throw( parameter => 'data' )
        unless exists $params->{data};

    my $field = $params->{field};
    my $data  = $params->{data};

    return try {
        $self->$field( $data ? $self->_json->encode($data) : undef );
    } catch {
        Koha::Exceptions::Object::BadValue->throw("Error reading JSON data: $_");
    };
}

=head2 Internal methods

=head3 _json

    my $JSON_object = $self->_json;

Returns a JSON object with utf8 disabled. Encoding to UTF-8 should be
done later.

=cut

sub _json {
    my ($self) = @_;
    $self->{_json} //= JSON->new->utf8(0);
    return $self->{_json};
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

=cut

1;
