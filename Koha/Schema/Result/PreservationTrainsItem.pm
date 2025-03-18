use utf8;
package Koha::Schema::Result::PreservationTrainsItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PreservationTrainsItem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<preservation_trains_items>

=cut

__PACKAGE__->table("preservation_trains_items");

=head1 ACCESSORS

=head2 train_item_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 train_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link with preservation_train

=head2 item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link with items

=head2 processing_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

specific processing for this item

=head2 user_train_item_id

  data_type: 'integer'
  is_nullable: 0

train item id for this train, starts from 1

=head2 added_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

added date

=cut

__PACKAGE__->add_columns(
  "train_item_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "train_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "processing_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "user_train_item_id",
  { data_type => "integer", is_nullable => 0 },
  "added_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</train_item_id>

=back

=cut

__PACKAGE__->set_primary_key("train_item_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<train_id>

=over 4

=item * L</train_id>

=item * L</item_id>

=back

=cut

__PACKAGE__->add_unique_constraint("train_id", ["train_id", "item_id"]);

=head1 RELATIONS

=head2 item

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "item_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 preservation_processing_attributes_items

Type: has_many

Related object: L<Koha::Schema::Result::PreservationProcessingAttributesItem>

=cut

__PACKAGE__->has_many(
  "preservation_processing_attributes_items",
  "Koha::Schema::Result::PreservationProcessingAttributesItem",
  { "foreign.train_item_id" => "self.train_item_id" },
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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 train

Type: belongs_to

Related object: L<Koha::Schema::Result::PreservationTrain>

=cut

__PACKAGE__->belongs_to(
  "train",
  "Koha::Schema::Result::PreservationTrain",
  { train_id => "train_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-17 18:47:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lpvjaV+qXrIDVlimBaycgA

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Preservation::Train::Item';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Preservation::Train::Items';
}

1;
