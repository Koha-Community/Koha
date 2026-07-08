use utf8;
package Koha::Schema::Result::ItemListContent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemListContent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_list_contents>

=cut

__PACKAGE__->table("item_list_contents");

=head1 ACCESSORS

=head2 item_list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the item list this item belongs to

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the item contained in the item list

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

when this item was added to the list

=cut

__PACKAGE__->add_columns(
  "item_list_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</item_list_id>

=item * L</itemnumber>

=back

=cut

__PACKAGE__->set_primary_key("item_list_id", "itemnumber");

=head1 RELATIONS

=head2 item_list

Type: belongs_to

Related object: L<Koha::Schema::Result::ItemList>

=cut

__PACKAGE__->belongs_to(
  "item_list",
  "Koha::Schema::Result::ItemList",
  { id => "item_list_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-08-27 10:43:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1MPNrQBXN3yi2sCmVjWZrw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head2 koha_object_class

The object class associated with this Result

=cut

sub koha_object_class {
    'Koha::Item::ListContent';
}

=head2 koha_objects_class

The object set class associated with this Result

=cut

sub koha_objects_class {
    'Koha::Item::ListContents';
}

1;
