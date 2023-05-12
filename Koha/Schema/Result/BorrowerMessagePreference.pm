use utf8;
package Koha::Schema::Result::BorrowerMessagePreference;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerMessagePreference

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_message_preferences>

=cut

__PACKAGE__->table("borrower_message_preferences");

=head1 ACCESSORS

=head2 borrower_message_preference_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 categorycode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 message_attribute_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 1

=head2 days_in_advance

  data_type: 'integer'
  is_nullable: 1

=head2 wants_digest

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "borrower_message_preference_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "categorycode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "message_attribute_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "days_in_advance",
  { data_type => "integer", is_nullable => 1 },
  "wants_digest",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrower_message_preference_id>

=back

=cut

__PACKAGE__->set_primary_key("borrower_message_preference_id");

=head1 RELATIONS

=head2 borrower_message_transport_preferences

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerMessageTransportPreference>

=cut

__PACKAGE__->has_many(
  "borrower_message_transport_preferences",
  "Koha::Schema::Result::BorrowerMessageTransportPreference",
  {
    "foreign.borrower_message_preference_id" => "self.borrower_message_preference_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 categorycode

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "categorycode",
  "Koha::Schema::Result::Category",
  { categorycode => "categorycode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 message_attribute

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageAttribute>

=cut

__PACKAGE__->belongs_to(
  "message_attribute",
  "Koha::Schema::Result::MessageAttribute",
  { message_attribute_id => "message_attribute_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 message_transport_types

Type: many_to_many

Composing rels: L</borrower_message_transport_preferences> -> message_transport_type

=cut

__PACKAGE__->many_to_many(
  "message_transport_types",
  "borrower_message_transport_preferences",
  "message_transport_type",
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-12 20:33:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KVYT5xqcXSDijZBaEHLV+g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
