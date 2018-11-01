package Koha::Object::Mixin::AdditionalFields;

use Modern::Perl;
use Koha::AdditionalFieldValues;

=head1 NAME

Koha::Object::Mixin::AdditionalFields

=head1 SYNOPSIS

    package Koha::Foo;

    use parent qw( Koha::Object Koha::Object::Mixin::AdditionalFields );

    sub _type { 'Foo' }


    package main;

    use Koha::Foo;

    Koha::Foos->find($id)->set_additional_fields(...);

=head1 API

=head2 Public methods

=head3 set_additional_fields

    $foo->set_additional_fields([
        {
            id => 1,
            value => 'foo',
        },
        {
            id => 2,
            value => 'bar',
        }
    ]);

=cut

sub set_additional_fields {
    my ($self, $additional_fields) = @_;

    $self->additional_field_values->delete;

    foreach my $additional_field (@$additional_fields) {
        my $value = $additional_field->{value};
        if (defined $value) {
            my $field_value = Koha::AdditionalFieldValue->new({
                field_id => $additional_field->{id},
                record_id => $self->id,
                value => $value,
            })->store;
        }
    }
}

=head3 additional_field_values

Returns additional field values

    my @values = $foo->additional_field_values;

=cut

sub additional_field_values {
    my ($self) = @_;

    my $afv_rs = $self->_result->additional_field_values;
    return Koha::AdditionalFieldValues->_new_from_dbic( $afv_rs );
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 BibLibre

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later
version.

Koha is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with Koha; if not, see <http://www.gnu.org/licenses>.

=cut

1;
