use utf8;
package Koha::Schema::Result::Virtualshelve;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Virtualshelve

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<virtualshelves>

=cut

__PACKAGE__->table("virtualshelves");

=head1 ACCESSORS

=head2 shelfnumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 shelfname

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 owner

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 category

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 sortfield

  data_type: 'varchar'
  default_value: 'title'
  is_nullable: 1
  size: 16

=head2 lastmodified

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 created_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 allow_add

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 allow_delete_own

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 allow_delete_other

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "shelfnumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "shelfname",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "owner",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "category",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "sortfield",
  {
    data_type => "varchar",
    default_value => "title",
    is_nullable => 1,
    size => 16,
  },
  "lastmodified",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "created_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "allow_add",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "allow_delete_own",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "allow_delete_other",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</shelfnumber>

=back

=cut

__PACKAGE__->set_primary_key("shelfnumber");

=head1 RELATIONS

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
    on_update     => "SET NULL",
  },
);

=head2 virtualshelfcontents

Type: has_many

Related object: L<Koha::Schema::Result::Virtualshelfcontent>

=cut

__PACKAGE__->has_many(
  "virtualshelfcontents",
  "Koha::Schema::Result::Virtualshelfcontent",
  { "foreign.shelfnumber" => "self.shelfnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 virtualshelfshares

Type: has_many

Related object: L<Koha::Schema::Result::Virtualshelfshare>

=cut

__PACKAGE__->has_many(
  "virtualshelfshares",
  "Koha::Schema::Result::Virtualshelfshare",
  { "foreign.shelfnumber" => "self.shelfnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-09-06 09:35:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wfAdz7LrmH49vdJ3f5rsmA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
