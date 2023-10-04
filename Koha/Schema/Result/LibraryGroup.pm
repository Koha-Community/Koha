use utf8;
package Koha::Schema::Result::LibraryGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LibraryGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<library_groups>

=cut

__PACKAGE__->table("library_groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique id for each group

=head2 parent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

if this is a child group, the id of the parent group

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

The branchcode of a branch belonging to the parent group

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 100

Short description of the goup

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

Longer explanation of the group, if necessary

=head2 ft_hide_patron_info

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Turn on the feature 'Hide patron's info' for this group

=head2 ft_limit_item_editing

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Turn on the feature "Limit item editing by group" for this group

=head2 ft_search_groups_opac

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Use this group for staff side search groups

=head2 ft_search_groups_staff

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Use this group for opac side search groups

=head2 ft_local_hold_group

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Use this group to identify libraries as pick up location for holds

=head2 ft_local_float_group

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Use this group to identify libraries as part of float group

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Date and time of creation

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Date and time of last

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "parent_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "ft_hide_patron_info",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "ft_limit_item_editing",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "ft_search_groups_opac",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "ft_search_groups_staff",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "ft_local_hold_group",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "ft_local_float_group",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
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

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<library_groups_uniq_2>

=over 4

=item * L</parent_id>

=item * L</branchcode>

=back

=cut

__PACKAGE__->add_unique_constraint("library_groups_uniq_2", ["parent_id", "branchcode"]);

=head2 C<title>

=over 4

=item * L</title>

=back

=cut

__PACKAGE__->add_unique_constraint("title", ["title"]);

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 library_groups

Type: has_many

Related object: L<Koha::Schema::Result::LibraryGroup>

=cut

__PACKAGE__->has_many(
  "library_groups",
  "Koha::Schema::Result::LibraryGroup",
  { "foreign.parent_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Koha::Schema::Result::LibraryGroup>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Koha::Schema::Result::LibraryGroup",
  { id => "parent_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-04 17:58:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M9YgMuCWhncegAzkH8uoJg

sub koha_object_class {
    'Koha::Library::Group';
}
sub koha_objects_class {
    'Koha::Library::Groups';
}

__PACKAGE__->add_columns(
    '+ft_hide_patron_info'    => { is_boolean => 1 },
    '+ft_limit_item_editing'  => { is_boolean => 1 },
    '+ft_local_float_group'   => { is_boolean => 1 },
    '+ft_local_hold_group'    => { is_boolean => 1 },
    '+ft_search_groups_opac'  => { is_boolean => 1 },
    '+ft_search_groups_staff' => { is_boolean => 1 },
);

1;
