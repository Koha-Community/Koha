use utf8;
package Koha::Schema::Result::MarcMergeRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcMergeRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_merge_rules>

=cut

__PACKAGE__->table("marc_merge_rules");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 tag

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 module

  data_type: 'varchar'
  is_nullable: 0
  size: 127

=head2 filter

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 add

  data_type: 'tinyint'
  is_nullable: 0

=head2 append

  data_type: 'tinyint'
  is_nullable: 0

=head2 remove

  data_type: 'tinyint'
  is_nullable: 0

=head2 delete

  accessor: undef
  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tag",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "module",
  { data_type => "varchar", is_nullable => 0, size => 127 },
  "filter",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "add",
  { data_type => "tinyint", is_nullable => 0 },
  "append",
  { data_type => "tinyint", is_nullable => 0 },
  "remove",
  { data_type => "tinyint", is_nullable => 0 },
  "delete",
  { accessor => undef, data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2021-02-10 16:31:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jdTzjEX0dUsXzK7LtlOS9w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
