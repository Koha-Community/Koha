package Koha::AdditionalField;

=head1 NAME

Koha::AdditionalField - Koha::Object derived class for additional fields

=cut

use Modern::Perl;

use base qw(Koha::Object);

use C4::Context;
use Koha::MarcSubfieldStructures;

=head1 METHODS

=head2 effective_authorised_value_category

Returns the authorised value category of the additional field or the authorised
value category of the MARC field, if any.

    my $av_category = $additional_field->effective_authorised_value_category;

=cut

sub effective_authorised_value_category {
    my ($self) = @_;

    my $category = $self->authorised_value_category;
    unless ($category) {
        if ( $self->marcfield ) {
            my ( $tag, $subfield ) = split /\$/, $self->marcfield;

            my $mss = Koha::MarcSubfieldStructures->find( '', $tag, $subfield );
            if ($mss) {
                $category = $mss->authorised_value;
            }
        }
    }

    return $category;
}

=head3 to_api

    my $json = $additional_field_type->to_api;

Overloaded method that returns a JSON representation of the Koha::AdditionalField
object, suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $table_to_resource = {
        'accountlines:credit'  => 'credit',
        'accountlines:debit'   => 'debit',
        'aqbasket'             => 'basket',
        'aqinvoices'           => 'invoice',
        'erm_licenses'         => 'license',
        'erm_agreements'       => 'agreement',
        'erm_packages'         => 'package',
        'aqorders'             => 'order',
        'aqbooksellers:vendor' => 'vendor',
        'erm_titles'           => 'title'
    };

    my $json = $self->SUPER::to_api($params);

    $json->{resource_type} = $table_to_resource->{ $self->tablename } || $self->tablename;

    return $json;
}

=head3 to_api_mapping

This method returns the mapping for representing an AdditionalField object
on the API.

=cut

sub to_api_mapping {
    return {
        id                        => 'extended_attribute_type_id',
        tablename                 => 'resource_type',
        authorised_value_category => 'authorised_value_category_name',
        marcfield                 => 'marc_field',
        marcfield_mode            => 'marc_field_mode'
    };
}

sub _type { 'AdditionalField' }

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=head1 COPYRIGHT AND LICENSE

Copyright 2013, 2018 BibLibre

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

=head1 SEE ALSO

L<Koha::Object>

=cut

1;
