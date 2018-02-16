use utf8;
package Koha::Schema::Result::MarcModificationTemplateAction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcModificationTemplateAction

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_modification_template_actions>

=cut

__PACKAGE__->table("marc_modification_template_actions");

=head1 ACCESSORS

=head2 mmta_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 template_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ordering

  data_type: 'integer'
  is_nullable: 0

=head2 action

  data_type: 'enum'
  extra: {list => ["delete_field","update_field","move_field","copy_field","copy_and_replace_field"]}
  is_nullable: 0

=head2 field_number

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 from_field

  data_type: 'varchar'
  is_nullable: 0
  size: 3

=head2 from_subfield

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 field_value

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 to_field

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 to_subfield

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 to_regex_search

  data_type: 'mediumtext'
  is_nullable: 1

=head2 to_regex_replace

  data_type: 'mediumtext'
  is_nullable: 1

=head2 to_regex_modifiers

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 8

=head2 conditional

  data_type: 'enum'
  extra: {list => ["if","unless"]}
  is_nullable: 1

=head2 conditional_field

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 conditional_subfield

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 conditional_comparison

  data_type: 'enum'
  extra: {list => ["exists","not_exists","equals","not_equals"]}
  is_nullable: 1

=head2 conditional_value

  data_type: 'mediumtext'
  is_nullable: 1

=head2 conditional_regex

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "mmta_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "template_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ordering",
  { data_type => "integer", is_nullable => 0 },
  "action",
  {
    data_type => "enum",
    extra => {
      list => [
        "delete_field",
        "update_field",
        "move_field",
        "copy_field",
        "copy_and_replace_field",
      ],
    },
    is_nullable => 0,
  },
  "field_number",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "from_field",
  { data_type => "varchar", is_nullable => 0, size => 3 },
  "from_subfield",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "field_value",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "to_field",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "to_subfield",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "to_regex_search",
  { data_type => "mediumtext", is_nullable => 1 },
  "to_regex_replace",
  { data_type => "mediumtext", is_nullable => 1 },
  "to_regex_modifiers",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 8 },
  "conditional",
  {
    data_type => "enum",
    extra => { list => ["if", "unless"] },
    is_nullable => 1,
  },
  "conditional_field",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "conditional_subfield",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "conditional_comparison",
  {
    data_type => "enum",
    extra => { list => ["exists", "not_exists", "equals", "not_equals"] },
    is_nullable => 1,
  },
  "conditional_value",
  { data_type => "mediumtext", is_nullable => 1 },
  "conditional_regex",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</mmta_id>

=back

=cut

__PACKAGE__->set_primary_key("mmta_id");

=head1 RELATIONS

=head2 template

Type: belongs_to

Related object: L<Koha::Schema::Result::MarcModificationTemplate>

=cut

__PACKAGE__->belongs_to(
  "template",
  "Koha::Schema::Result::MarcModificationTemplate",
  { template_id => "template_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uRkJ8yckBiNtsYgUt8BpEw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
