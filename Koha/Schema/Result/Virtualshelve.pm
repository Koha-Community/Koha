package Koha::Schema::Result::Virtualshelve;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Virtualshelve

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
  is_nullable: 1
  size: 16

=head2 lastmodified

  data_type: 'timestamp'
  default_value: current_timestamp
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
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "lastmodified",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "allow_add",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "allow_delete_own",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "allow_delete_other",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("shelfnumber");

=head1 RELATIONS

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

=head2 owner

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "owner" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GitYLGGw2F/bqc511p2oTg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
