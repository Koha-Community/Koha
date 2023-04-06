package Koha::Preservation::Processing;

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

use base qw(Koha::Object);

use Koha::Preservation::Processing::Attributes;

=head1 NAME

Koha::Preservation::Processing - Koha Processing Object class

=head1 API

=head2 Class methods

=cut

=head3 attributes

Set or return the attributes for this processing

=cut

sub attributes {
    my ( $self, $attributes ) = @_;

    if ( $attributes ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                my @existing_ids = map { $_->{processing_attribute_id} || () } @$attributes;
                if (@existing_ids || !@$attributes) {
                    $self->attributes->search(
                        {
                            (
                                # If no attributes passed we delete all the existing ones
                                @$attributes
                                ? (
                                    processing_attribute_id => {
                                        -not_in => \@existing_ids
                                    }
                                  )
                                : ()
                            )
                        }
                    )->delete;
                }

                for my $attribute (@$attributes) {
                    my $existing_attribute = $self->attributes->find( $attribute->{processing_attribute_id} );
                    if ($existing_attribute) {
                        $existing_attribute->set($attribute)->store;
                    } else {
                        $self->_result ->add_to_preservation_processing_attributes( $attribute );
                    }
                }
            }
        );
    }

    my $attributes_rs = $self->_result->preservation_processing_attributes;
    return Koha::Preservation::Processing::Attributes->_new_from_dbic($attributes_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'PreservationProcessing';
}

1;
