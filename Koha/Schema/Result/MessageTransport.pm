use utf8;
package Koha::Schema::Result::MessageTransport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MessageTransport

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<message_transports>

=cut

__PACKAGE__->table("message_transports");

=head1 ACCESSORS

=head2 message_attribute_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 message_transport_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 is_digest

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 letter_module

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 letter_code

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "message_attribute_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "message_transport_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "is_digest",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "letter_module",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 20,
  },
  "letter_code",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 20,
  },
  "branchcode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</message_attribute_id>

=item * L</message_transport_type>

=item * L</is_digest>

=back

=cut

__PACKAGE__->set_primary_key("message_attribute_id", "message_transport_type", "is_digest");

=head1 RELATIONS

=head2 letter

Type: belongs_to

Related object: L<Koha::Schema::Result::Letter>

=cut

__PACKAGE__->belongs_to(
  "letter",
  "Koha::Schema::Result::Letter",
  {
    branchcode => "branchcode",
    code => "letter_code",
    module => "letter_module",
  },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 message_attribute

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageAttribute>

=cut

__PACKAGE__->belongs_to(
  "message_attribute",
  "Koha::Schema::Result::MessageAttribute",
  { message_attribute_id => "message_attribute_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 message_transport_type

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageTransportType>

=cut

__PACKAGE__->belongs_to(
  "message_transport_type",
  "Koha::Schema::Result::MessageTransportType",
  { message_transport_type => "message_transport_type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P4Bsq0A7/imUhRBRnD5HrQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
