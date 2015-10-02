use utf8;
package Koha::Schema::Result::AdditionalField;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AdditionalField

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<additional_fields>

=cut

__PACKAGE__->table("additional_fields");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 tablename

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 authorised_value_category

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 marcfield

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 searchable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tablename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "authorised_value_category",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 16 },
  "marcfield",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 16 },
  "searchable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<fields_uniq>

=over 4

=item * L</tablename>

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("fields_uniq", ["tablename", "name"]);

=head1 RELATIONS

=head2 additional_field_values

Type: has_many

Related object: L<Koha::Schema::Result::AdditionalFieldValue>

=cut

__PACKAGE__->has_many(
  "additional_field_values",
  "Koha::Schema::Result::AdditionalFieldValue",
  { "foreign.field_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-10-02 15:12:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vvz9GJNkU4K7bftDNuRHVA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
