use utf8;
package Koha::Schema::Result::CreatorLayout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CreatorLayout

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<creator_layouts>

=cut

__PACKAGE__->table("creator_layouts");

=head1 ACCESSORS

=head2 layout_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 barcode_type

  data_type: 'char'
  default_value: 'CODE39'
  is_nullable: 0
  size: 100

=head2 start_label

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 printing_type

  data_type: 'char'
  default_value: 'BAR'
  is_nullable: 0
  size: 32

=head2 layout_name

  data_type: 'char'
  default_value: 'DEFAULT'
  is_nullable: 0
  size: 25

=head2 guidebox

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 oblique_title

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 font

  data_type: 'char'
  default_value: 'TR'
  is_nullable: 0
  size: 10

=head2 font_size

  data_type: 'integer'
  default_value: 10
  is_nullable: 0

=head2 units

  data_type: 'char'
  default_value: 'POINT'
  is_nullable: 0
  size: 20

=head2 callnum_split

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 text_justify

  data_type: 'char'
  default_value: 'L'
  is_nullable: 0
  size: 1

=head2 format_string

  data_type: 'varchar'
  default_value: 'barcode'
  is_nullable: 0
  size: 210

=head2 layout_xml

  data_type: 'mediumtext'
  is_nullable: 0

=head2 creator

  data_type: 'char'
  default_value: 'Labels'
  is_nullable: 0
  size: 15

=cut

__PACKAGE__->add_columns(
  "layout_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "barcode_type",
  {
    data_type => "char",
    default_value => "CODE39",
    is_nullable => 0,
    size => 100,
  },
  "start_label",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "printing_type",
  { data_type => "char", default_value => "BAR", is_nullable => 0, size => 32 },
  "layout_name",
  {
    data_type => "char",
    default_value => "DEFAULT",
    is_nullable => 0,
    size => 25,
  },
  "guidebox",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "oblique_title",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "font",
  { data_type => "char", default_value => "TR", is_nullable => 0, size => 10 },
  "font_size",
  { data_type => "integer", default_value => 10, is_nullable => 0 },
  "units",
  { data_type => "char", default_value => "POINT", is_nullable => 0, size => 20 },
  "callnum_split",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "text_justify",
  { data_type => "char", default_value => "L", is_nullable => 0, size => 1 },
  "format_string",
  {
    data_type => "varchar",
    default_value => "barcode",
    is_nullable => 0,
    size => 210,
  },
  "layout_xml",
  { data_type => "mediumtext", is_nullable => 0 },
  "creator",
  {
    data_type => "char",
    default_value => "Labels",
    is_nullable => 0,
    size => 15,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</layout_id>

=back

=cut

__PACKAGE__->set_primary_key("layout_id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GdBVaqH0rfn1Jy/t57ieNA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
