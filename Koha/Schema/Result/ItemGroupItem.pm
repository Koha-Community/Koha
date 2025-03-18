use utf8;
package Koha::Schema::Result::ItemGroupItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemGroupItem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_group_items>

=cut

__PACKAGE__->table("item_group_items");

=head1 ACCESSORS

=head2 item_group_items_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

id for the group/item link

=head2 item_group_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

foreign key making this table a 1 to 1 join from items to item groups

=head2 item_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

foreign key linking this table to the items table

=cut

__PACKAGE__->add_columns(
  "item_group_items_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "item_group_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "item_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</item_group_items_id>

=back

=cut

__PACKAGE__->set_primary_key("item_group_items_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<item_id>

=over 4

=item * L</item_id>

=back

=cut

__PACKAGE__->add_unique_constraint("item_id", ["item_id"]);

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

=head2 item_group

Type: belongs_to

Related object: L<Koha::Schema::Result::ItemGroup>

=cut

__PACKAGE__->belongs_to(
  "item_group",
  "Koha::Schema::Result::ItemGroup",
  { item_group_id => "item_group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-06-02 16:18:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FLtrDLTHqXdzqyOmVvaXJQ

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Biblio::ItemGroup::Item';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Biblio::ItemGroup::Items';
}

1;
