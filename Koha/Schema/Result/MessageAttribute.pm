use utf8;
package Koha::Schema::Result::MessageAttribute;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MessageAttribute

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<message_attributes>

=cut

__PACKAGE__->table("message_attributes");

=head1 ACCESSORS

=head2 message_attribute_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 message_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 takes_days

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "message_attribute_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "message_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "takes_days",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</message_attribute_id>

=back

=cut

__PACKAGE__->set_primary_key("message_attribute_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<message_name>

=over 4

=item * L</message_name>

=back

=cut

__PACKAGE__->add_unique_constraint("message_name", ["message_name"]);

=head1 RELATIONS

=head2 borrower_message_preferences

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerMessagePreference>

=cut

__PACKAGE__->has_many(
  "borrower_message_preferences",
  "Koha::Schema::Result::BorrowerMessagePreference",
  { "foreign.message_attribute_id" => "self.message_attribute_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 message_transports

Type: has_many

Related object: L<Koha::Schema::Result::MessageTransport>

=cut

__PACKAGE__->has_many(
  "message_transports",
  "Koha::Schema::Result::MessageTransport",
  { "foreign.message_attribute_id" => "self.message_attribute_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N033AvWwG2CDBDuTj2unqQ


# You can replace this text with custom content, and it will be preserved on regeneration

sub koha_object_class {
  'Koha::Patron::MessagePreference::Attribute';
}
sub koha_objects_class {
  'Koha::Patron::MessagePreference::Attributes';
}

1;
