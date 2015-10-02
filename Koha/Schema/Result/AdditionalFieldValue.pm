use utf8;
package Koha::Schema::Result::AdditionalFieldValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AdditionalFieldValue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<additional_field_values>

=cut

__PACKAGE__->table("additional_field_values");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 field_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 record_id

  data_type: 'integer'
  is_nullable: 0

=head2 value

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "field_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "record_id",
  { data_type => "integer", is_nullable => 0 },
  "value",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<field_record>

=over 4

=item * L</field_id>

=item * L</record_id>

=back

=cut

__PACKAGE__->add_unique_constraint("field_record", ["field_id", "record_id"]);

=head1 RELATIONS

=head2 field

Type: belongs_to

Related object: L<Koha::Schema::Result::AdditionalField>

=cut

__PACKAGE__->belongs_to(
  "field",
  "Koha::Schema::Result::AdditionalField",
  { id => "field_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-10-02 15:12:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a9G6nhDU9dBDcRRN0vzkLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
