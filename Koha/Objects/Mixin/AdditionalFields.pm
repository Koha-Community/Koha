package Koha::Objects::Mixin::AdditionalFields;

use Modern::Perl;

use base qw(Koha::Objects::Mixin::ExtendedAttributes);

=head1 NAME

Koha::Objects::Mixin::AdditionalFields

=head1 SYNOPSIS

    package Koha::Foos;

    use parent qw( Koha::Objects Koha::Objects::Mixin::AdditionalFields );

    sub _type { 'Foo' }
    sub object_class { 'Koha::Foo' }


    package main;

    use Koha::Foos;

    Koha::Foos->filter_by_additional_fields(...)

=head1 API

=head2 Public methods

=head3 filter_by_additional_fields

    my $objects = Koha::Foos->filter_by_additional_fields([
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

sub filter_by_additional_fields {
    my ( $class, $additional_fields ) = @_;

    my %conditions;
    my $idx = 0;
    foreach my $additional_field (@$additional_fields) {
        ++$idx;
        my $alias = $idx > 1 ? "additional_field_values_$idx" : "additional_field_values";
        $conditions{"$alias.field_id"} = $additional_field->{id};
        $conditions{"$alias.value"}    = { -like => '%' . $additional_field->{value} . '%' };
    }

    return $class->search( \%conditions, { join => [ ('additional_field_values') x $idx ] } );
}

=head3 extended_attributes_config

    Returns a hash containing the configuration for extended attributes

=cut

sub extended_attributes_config {
    my ($self) = @_;

    return {
        'id_field'     => { 'foreign' => 'record_id', 'self' => $self->_resultset->result_source->primary_columns },
        'key_field'    => 'field_id',
        'schema_class' => 'Koha::Schema::Result::AdditionalFieldValue',
    };
}

=head3 extended_attributes_tablename_query

    Returns a hash containing the tablename and operator for extended attributes.

=cut

sub extended_attributes_tablename_query {
    my ($self) = @_;

    return { 'tablename' => $self->_resultset->result_source->name, 'operator' => '=' };
}

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

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
with Koha; if not, see <https://www.gnu.org/licenses>.

=cut

1;
