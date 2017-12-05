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

=head2 parent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 created_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 updated_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

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
  { data_type => "text", is_nullable => 1 },
  "created_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "updated_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-12-05 14:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:p4hmm+ciFgPOGlAMvNB6Yw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
