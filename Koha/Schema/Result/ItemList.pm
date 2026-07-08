use utf8;
package Koha::Schema::Result::ItemList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemList

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_lists>

=cut

__PACKAGE__->table("item_lists");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique id for the item list

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

name of the item list

=head2 owner

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrowernumber of the item list owner

=head2 visibility

  data_type: 'enum'
  default_value: 'private'
  extra: {list => ["private","group","public"]}
  is_nullable: 0

visibility determining ability to read the item list

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

when the item list was created

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

when the item list was last updated

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "owner",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "visibility",
  {
    data_type => "enum",
    default_value => "private",
    extra => { list => ["private", "group", "public"] },
    is_nullable => 0,
  },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
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

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 item_list_contents

Type: has_many

Related object: L<Koha::Schema::Result::ItemListContent>

=cut

__PACKAGE__->has_many(
  "item_list_contents",
  "Koha::Schema::Result::ItemListContent",
  { "foreign.item_list_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 item_list_shares

Type: has_many

Related object: L<Koha::Schema::Result::ItemListShare>

=cut

__PACKAGE__->has_many(
  "item_list_shares",
  "Koha::Schema::Result::ItemListShare",
  { "foreign.item_list_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owner

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "owner" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-08-27 10:38:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uxr/3wfj0mZEEiP/5CqnPw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
