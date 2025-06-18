package Koha::Preservation::Train::Item::Attribute;

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

use JSON qw( to_json );
use Try::Tiny;

use Koha::AuthorisedValues;

use base qw(Koha::Object);

use Koha::Preservation::Processing::Attributes;

=head1 NAME

Koha::Preservation::Train::Item::Attribute - Koha Train::Item::Attribute Object class

=head1 API

=head2 Class methods

=cut

=head3 processing_attribute

my $processing_attribute = $attribute->processing_attribute;

Return the Koha::Preservation::Processing::Attribute object

=cut

sub processing_attribute {
    my ($self) = @_;
    my $processing_attribute_rs = $self->_result->processing_attribute;
    return Koha::Preservation::Processing::Attribute->_new_from_dbic($processing_attribute_rs);
}

=head3 strings_map

Returns a map of column name to string representations including the string.

=cut

sub strings_map {
    my ($self) = @_;
    my $str = $self->value;
    if ( $self->processing_attribute->type eq 'authorised_value' ) {
        my $av = Koha::AuthorisedValues->search(
            {
                category         => $self->processing_attribute->option_source,
                authorised_value => $self->value,
            }
        );
        if ( $av->count ) {
            $str = $av->next->lib || $self->value;
        }
    }

    return {
        value => { str => $str, type => 'authorised_value' },
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'PreservationProcessingAttributesItem';
}

1;
