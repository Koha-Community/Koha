use utf8;
package Koha::Schema::Result::PreservationProcessingAttributesItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PreservationProcessingAttributesItem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<preservation_processing_attributes_items>

=cut

__PACKAGE__->table("preservation_processing_attributes_items");

=head1 ACCESSORS

=head2 processing_attribute_item_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 processing_attribute_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link with preservation_processing_attributes

=head2 train_item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link with preservation_trains_items

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

value for this attribute

=cut

__PACKAGE__->add_columns(
  "processing_attribute_item_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "processing_attribute_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "train_item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</processing_attribute_item_id>

=back

=cut

__PACKAGE__->set_primary_key("processing_attribute_item_id");

=head1 RELATIONS

=head2 processing_attribute

Type: belongs_to

Related object: L<Koha::Schema::Result::PreservationProcessingAttribute>

=cut

__PACKAGE__->belongs_to(
  "processing_attribute",
  "Koha::Schema::Result::PreservationProcessingAttribute",
  { processing_attribute_id => "processing_attribute_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 train_item

Type: belongs_to

Related object: L<Koha::Schema::Result::PreservationTrainsItem>

=cut

__PACKAGE__->belongs_to(
  "train_item",
  "Koha::Schema::Result::PreservationTrainsItem",
  { train_item_id => "train_item_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-24 13:35:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q7q8ThZAW9HGDWaemSTS3A

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Preservation::Train::Item::Attribute';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Preservation::Train::Item::Attributes';
}

1;
