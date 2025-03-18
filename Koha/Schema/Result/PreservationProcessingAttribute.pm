use utf8;
package Koha::Schema::Result::PreservationProcessingAttribute;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PreservationProcessingAttribute

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<preservation_processing_attributes>

=cut

__PACKAGE__->table("preservation_processing_attributes");

=head1 ACCESSORS

=head2 processing_attribute_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 processing_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the processing

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

name of the processing attribute

=head2 type

  data_type: 'enum'
  extra: {list => ["authorised_value","free_text","db_column"]}
  is_nullable: 0

Type of the processing attribute

=head2 option_source

  data_type: 'varchar'
  is_nullable: 1
  size: 80

source of the possible options for this attribute

=cut

__PACKAGE__->add_columns(
  "processing_attribute_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "processing_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "type",
  {
    data_type => "enum",
    extra => { list => ["authorised_value", "free_text", "db_column"] },
    is_nullable => 0,
  },
  "option_source",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</processing_attribute_id>

=back

=cut

__PACKAGE__->set_primary_key("processing_attribute_id");

=head1 RELATIONS

=head2 preservation_processing_attributes_items

Type: has_many

Related object: L<Koha::Schema::Result::PreservationProcessingAttributesItem>

=cut

__PACKAGE__->has_many(
  "preservation_processing_attributes_items",
  "Koha::Schema::Result::PreservationProcessingAttributesItem",
  {
    "foreign.processing_attribute_id" => "self.processing_attribute_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 processing

Type: belongs_to

Related object: L<Koha::Schema::Result::PreservationProcessing>

=cut

__PACKAGE__->belongs_to(
  "processing",
  "Koha::Schema::Result::PreservationProcessing",
  { processing_id => "processing_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-17 18:47:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i0vFmFYaqiZFyXGxDp+6oQ

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Preservation::Processing::Attributes';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Preservation::Processing::Attribute';
}

1;
