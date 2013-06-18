package Koha::Schema::Result::TagsIndex;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::TagsIndex

=cut

__PACKAGE__->table("tags_index");

=head1 ACCESSORS

=head2 term

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 weight

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "term",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "weight",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("term", "biblionumber");

=head1 RELATIONS

=head2 term

Type: belongs_to

Related object: L<Koha::Schema::Result::TagsApproval>

=cut

__PACKAGE__->belongs_to(
  "term",
  "Koha::Schema::Result::TagsApproval",
  { term => "term" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X0OvXQjDYLVCMgHHWx/kpw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
