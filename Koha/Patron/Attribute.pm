package Koha::Patron::Attribute;

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

use Koha::Database;
use Koha::Exceptions::Patron::Attribute;
use Koha::Patron::Attribute::Types;

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

    $self->_check_repeatable;
    $self->_check_unique_id;

    return $self->SUPER::store();
}

=head3 opac_display

    my $attribute = Koha::Patron::Attribute->new({ code => 'a_code', ... });
    if ( $attribute->opac_display ) { ... }

=cut

sub opac_display {

    my $self = shift;

    return Koha::Patron::Attribute::Types->find( $self->code )->opac_display;
}

=head3 opac_editable

    my $attribute = Koha::Patron::Attribute->new({ code => 'a_code', ... });
    if ( $attribute->is_opac_editable ) { ... }

=cut

sub opac_editable {

    my $self = shift;

    return Koha::Patron::Attribute::Types->find( $self->code )->opac_editable;
}

=head3 type

    my $attribute_type = $attribute->type;

Returns a C<Koha::Patron::Attribute::Type> object corresponding to the current patron attribute

=cut

sub type {

    my $self = shift;

    return Koha::Patron::Attribute::Types->find( $self->code );
}

=head2 Internal methods

=head3 _check_repeatable

_check_repeatable checks if the attribute type is repeatable and throws and exception
if the attribute type isn't repeatable and there's already an attribute with the same
code for the given patron.

=cut

sub _check_repeatable {

    my $self = shift;

    if ( !$self->type->repeatable ) {
        my $attr_count = Koha::Patron::Attributes->search(
            {   borrowernumber => $self->borrowernumber,
                code           => $self->code
            }
            )->count;
        Koha::Exceptions::Patron::Attribute::NonRepeatable->throw()
            if $attr_count > 0;
    }

    return $self;
}

=head3 _check_unique_id

_check_unique_id checks if the attribute type is marked as unique id and throws and exception
if the attribute type is a unique id and there's already an attribute with the same
code and value on the database.

=cut

sub _check_unique_id {

    my $self = shift;

    if ( $self->type->unique_id ) {
        my $unique_count = Koha::Patron::Attributes
            ->search( { code => $self->code, attribute => $self->attribute } )
            ->count;
        Koha::Exceptions::Patron::Attribute::UniqueIDConstraint->throw()
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
