use utf8;
package Koha::Schema::Result::Collection;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Collection

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<collections>

=cut

__PACKAGE__->table("collections");

=head1 ACCESSORS

=head2 colId

  accessor: 'col_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 colTitle

  accessor: 'col_title'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 colDesc

  accessor: 'col_desc'
  data_type: 'text'
  is_nullable: 0

=head2 colBranchcode

  accessor: 'col_branchcode'
  data_type: 'varchar'
  is_nullable: 1
  size: 4

branchcode for branch where item should be held.

=cut

__PACKAGE__->add_columns(
  "colId",
  {
    accessor          => "col_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "colTitle",
  {
    accessor => "col_title",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 100,
  },
  "colDesc",
  { accessor => "col_desc", data_type => "text", is_nullable => 0 },
  "colBranchcode",
  {
    accessor => "col_branchcode",
    data_type => "varchar",
    is_nullable => 1,
    size => 4,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</colId>

=back

=cut

__PACKAGE__->set_primary_key("colId");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-08-18 13:01:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4QFGZYwbv0aj6eXdn7vO9A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
