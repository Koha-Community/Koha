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

primary key identifier

=head2 tablename

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

tablename of the new field

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

name of the field

=head2 authorised_value_category

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

is an authorised value category

=head2 marcfield

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 16

contains the marc field to copied into the record

=head2 marcfield_mode

  data_type: 'enum'
  default_value: 'get'
  extra: {list => ["get","set"]}
  is_nullable: 0

mode of operation (get or set) for marcfield

=head2 searchable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

is the field searchable?

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tablename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "authorised_value_category",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "marcfield",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 16 },
  "marcfield_mode",
  {
    data_type => "enum",
    default_value => "get",
    extra => { list => ["get", "set"] },
    is_nullable => 0,
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-15 17:35:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q1mpEq5S0nZAOVXHqz+hEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
