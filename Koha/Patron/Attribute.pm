package Koha::Patron::Attribute;

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

use Koha::Database;
use Koha::Exceptions::Patron::Attribute;
use Koha::Patron::Attribute::Types;
use Koha::AuthorisedValues;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Attribute - Koha Patron Attribute Object class

=head1 API

=head2 Class Methods

=cut

=head3 store

    my $attribute = Koha::Patron::Attribute->new({ code => 'a_code', ... });
    try { $attribute->store }
    catch { handle_exception };

=cut

sub store {

    my $self = shift;

    my $type = $self->type;

    Koha::Exceptions::Patron::Attribute::InvalidType->throw( type => $self->code )
        unless $type;

    $self->check_repeatable($type);
    $self->check_unique_id($type);

    return $self->SUPER::store();
}

=head3 type

    my $attribute_type = $attribute->type;

Returns a C<Koha::Patron::Attribute::Type> object corresponding to the current patron attribute

=cut

sub type {

    my $self = shift;

    return scalar Koha::Patron::Attribute::Types->find( $self->code );
}

=head3 authorised_value

my $authorised_value = $attribute->authorised_value;

Return the Koha::AuthorisedValue object of this attribute when one is attached.

Return undef if this attribute is not attached to an authorised value

=cut

sub authorised_value {
    my ($self) = @_;

    return unless $self->type->authorised_value_category;

    my $av = Koha::AuthorisedValues->search(
        {
            category         => $self->type->authorised_value_category,
            authorised_value => $self->attribute,
        }
    );
    return unless $av->count; # Data inconsistency
    return $av->next;
}

=head3 description

my $description = $patron_attribute->description;

Return the value of this attribute or the description of the authorised value (when attached).

This method must be called when the authorised value's description must be
displayed instead of the code.

=cut

sub description {
    my ( $self) = @_;
    if ( $self->type->authorised_value_category ) {
        my $av = $self->authorised_value;
        return $av ? $av->lib : "";
    }
    return $self->attribute;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Patron::Attribute object
on the API.

=cut

sub to_api_mapping {
    return {
        id             => 'extended_attribute_id',
        attribute      => 'value',
        borrowernumber => undef,
        code           => 'type'
    };
}

=head2 Internal methods

=head3 check_repeatable

check_repeatable checks if the attribute type is repeatable and throws and exception
if the attribute type isn't repeatable and there's already an attribute with the same
code for the given patron.

=cut

sub check_repeatable {

    my ( $self, $type ) = @_;

    if ( !$type->repeatable ) {
        my $params = {
            borrowernumber => $self->borrowernumber,
            code           => $self->code
        };

        $params->{id} = { '!=' => $self->id }
            if $self->in_storage;

        Koha::Exceptions::Patron::Attribute::NonRepeatable->throw( attribute => $self )
            if Koha::Patron::Attributes->search($params)->count > 0;
    }

    return $self;
}

=head3 check_unique_id

check_unique_id checks if the attribute type is marked as unique id and throws and exception
if the attribute type is a unique id and there's already an attribute with the same
code and value on the database.

=cut

sub check_unique_id {

    my ( $self, $type ) = @_;

    if ( $type->unique_id ) {
        my $params = { code => $self->code, attribute => $self->attribute };

        $params->{borrowernumber} = { '!=' => $self->borrowernumber } if $self->borrowernumber;
        $params->{id}             = { '!=' => $self->id }             if $self->in_storage;

        my $unique_count = Koha::Patron::Attributes
            ->search( $params )
            ->count;
        Koha::Exceptions::Patron::Attribute::UniqueIDConstraint->throw( attribute => $self )
            if $unique_count > 0;
    }

    return $self;
}

=head3 _type

=cut

sub _type {
    return 'BorrowerAttribute';
}

1;
