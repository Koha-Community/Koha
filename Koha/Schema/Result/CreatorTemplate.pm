use utf8;
package Koha::Schema::Result::CreatorTemplate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CreatorTemplate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<creator_templates>

=cut

__PACKAGE__->table("creator_templates");

=head1 ACCESSORS

=head2 template_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 profile_id

  data_type: 'integer'
  is_nullable: 1

=head2 template_code

  data_type: 'char'
  default_value: 'DEFAULT TEMPLATE'
  is_nullable: 0
  size: 100

=head2 template_desc

  data_type: 'char'
  default_value: 'Default description'
  is_nullable: 0
  size: 100

=head2 page_width

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 page_height

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 label_width

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 label_height

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 top_text_margin

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 left_text_margin

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 top_margin

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 left_margin

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 cols

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 rows

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 col_gap

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 row_gap

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 units

  data_type: 'char'
  default_value: 'POINT'
  is_nullable: 0
  size: 20

=head2 creator

  data_type: 'char'
  default_value: 'Labels'
  is_nullable: 0
  size: 15

=cut

__PACKAGE__->add_columns(
  "template_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "profile_id",
  { data_type => "integer", is_nullable => 1 },
  "template_code",
  {
    data_type => "char",
    default_value => "DEFAULT TEMPLATE",
    is_nullable => 0,
    size => 100,
  },
  "template_desc",
  {
    data_type => "char",
    default_value => "Default description",
    is_nullable => 0,
    size => 100,
  },
  "page_width",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "page_height",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "label_width",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "label_height",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "top_text_margin",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "left_text_margin",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "top_margin",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "left_margin",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "cols",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "rows",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "col_gap",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "row_gap",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "units",
  { data_type => "char", default_value => "POINT", is_nullable => 0, size => 20 },
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

=item * L</template_id>

=back

=cut

__PACKAGE__->set_primary_key("template_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2NGDs68pqskZaoiyURPIGg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
