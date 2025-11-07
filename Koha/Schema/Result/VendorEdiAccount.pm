use utf8;
package Koha::Schema::Result::VendorEdiAccount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::VendorEdiAccount

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vendor_edi_accounts>

=cut

__PACKAGE__->table("vendor_edi_accounts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

=head2 last_activity

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 san

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 standard

  data_type: 'varchar'
  default_value: 'EUR'
  is_nullable: 1
  size: 3

=head2 id_code_qualifier

  data_type: 'varchar'
  default_value: 14
  is_nullable: 1
  size: 3

=head2 quotes_enabled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 invoices_enabled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 orders_enabled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 responses_enabled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 auto_orders

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 shipment_budget

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 plugin

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 256

=head2 file_transport_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 po_is_basketname

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "last_activity",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "san",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "standard",
  { data_type => "varchar", default_value => "EUR", is_nullable => 1, size => 3 },
  "id_code_qualifier",
  { data_type => "varchar", default_value => 14, is_nullable => 1, size => 3 },
  "quotes_enabled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "invoices_enabled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "orders_enabled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "responses_enabled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "auto_orders",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "shipment_budget",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "plugin",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 256 },
  "file_transport_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "po_is_basketname",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 edifact_messages

Type: has_many

Related object: L<Koha::Schema::Result::EdifactMessage>

=cut

__PACKAGE__->has_many(
  "edifact_messages",
  "Koha::Schema::Result::EdifactMessage",
  { "foreign.edi_acct" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 file_transport

Type: belongs_to

Related object: L<Koha::Schema::Result::FileTransport>

=cut

__PACKAGE__->belongs_to(
  "file_transport",
  "Koha::Schema::Result::FileTransport",
  { file_transport_id => "file_transport_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 shipment_budget

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "shipment_budget",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "shipment_budget" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-11-03 20:27:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1sHAak6V/HC2E1AUHzDapg

__PACKAGE__->add_columns(
    '+auto_orders'       => { is_boolean => 1 },
    '+invoices_enabled'  => { is_boolean => 1 },
    '+orders_enabled'    => { is_boolean => 1 },
    '+quotes_enabled'    => { is_boolean => 1 },
    '+responses_enabled' => { is_boolean => 1 },
    '+po_is_basketname'  => { is_boolean => 1 },
);

1;
