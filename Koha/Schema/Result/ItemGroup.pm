use utf8;
package Koha::Schema::Result::ItemGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_groups>

=cut

__PACKAGE__->table("item_groups");

=head1 ACCESSORS

=head2 item_group_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

id for the items group

=head2 biblio_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

id for the bibliographic record the group belongs to

=head2 display_order

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

The 'sort order' for item_groups

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

A group description

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Time and date the group was created

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Time and date of the latest change on the group

=cut

__PACKAGE__->add_columns(
  "item_group_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblio_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "display_order",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "updated_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</item_group_id>

=back

=cut

__PACKAGE__->set_primary_key("item_group_id");

=head1 RELATIONS

=head2 biblio

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblio",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblio_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 item_group_items

Type: has_many

Related object: L<Koha::Schema::Result::ItemGroupItem>

=cut

__PACKAGE__->has_many(
  "item_group_items",
  "Koha::Schema::Result::ItemGroupItem",
  { "foreign.item_group_id" => "self.item_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.item_group_id" => "self.item_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.item_group_id" => "self.item_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-10 17:06:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OPwObeUEFgzNwMYlEgHkQw

sub koha_objects_class {
    'Koha::Biblio::ItemGroups';
}
sub koha_object_class {
    'Koha::Biblio::ItemGroup';
}

1;
