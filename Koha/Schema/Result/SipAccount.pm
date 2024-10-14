use utf8;
package Koha::Schema::Result::SipAccount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipAccount

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_accounts>

=cut

__PACKAGE__->table("sip_accounts");

=head1 ACCESSORS

=head2 sip_account_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sip_institution_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Foreign key to sip_institutions.sip_institution_id

=head2 ae_field_template

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 allow_additional_materials_checkout

  data_type: 'tinyint'
  is_nullable: 1

=head2 allow_empty_passwords

  data_type: 'tinyint'
  is_nullable: 1

=head2 allow_fields

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 av_field_template

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 blocked_item_types

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 checked_in_ok

  data_type: 'tinyint'
  is_nullable: 1

=head2 convert_nonprinting_characters

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 cr_item_field

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 ct_always_send

  data_type: 'tinyint'
  is_nullable: 1

=head2 cv_send_00_on_success

  data_type: 'tinyint'
  is_nullable: 1

=head2 cv_triggers_alert

  data_type: 'tinyint'
  is_nullable: 1

=head2 da_field_template

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 delimiter

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 disallow_overpayment

  data_type: 'tinyint'
  is_nullable: 1

=head2 encoding

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 error_detect

  data_type: 'tinyint'
  is_nullable: 1

=head2 format_due_date

  data_type: 'tinyint'
  is_nullable: 1

=head2 hide_fields

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 holds_block_checkin

  data_type: 'tinyint'
  is_nullable: 1

=head2 holds_get_captured

  data_type: 'tinyint'
  is_nullable: 1

=head2 inhouse_item_types

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 inhouse_patron_categories

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 login_id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

PREVIOUSLY id in Sipconfig.xml

=head2 login_password

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 lost_status_for_missing

  data_type: 'tinyint'
  is_nullable: 1

actual tinyint, not boolean

=head2 overdues_block_checkout

  data_type: 'tinyint'
  is_nullable: 1

=head2 payment_type_writeoff

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 prevcheckout_block_checkout

  data_type: 'tinyint'
  is_nullable: 1

=head2 register_id

  data_type: 'integer'
  is_nullable: 1

SHOULD THIS BE A FK TO cash_registers?

=head2 seen_on_item_information

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 send_patron_home_library_in_af

  data_type: 'tinyint'
  is_nullable: 1

=head2 show_checkin_message

  data_type: 'tinyint'
  is_nullable: 1

=head2 show_outstanding_amount

  data_type: 'tinyint'
  is_nullable: 1

=head2 terminator

  data_type: 'enum'
  extra: {list => ["CR","CRLF"]}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "sip_account_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sip_institution_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ae_field_template",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "allow_additional_materials_checkout",
  { data_type => "tinyint", is_nullable => 1 },
  "allow_empty_passwords",
  { data_type => "tinyint", is_nullable => 1 },
  "allow_fields",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "av_field_template",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "blocked_item_types",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "checked_in_ok",
  { data_type => "tinyint", is_nullable => 1 },
  "convert_nonprinting_characters",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "cr_item_field",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "ct_always_send",
  { data_type => "tinyint", is_nullable => 1 },
  "cv_send_00_on_success",
  { data_type => "tinyint", is_nullable => 1 },
  "cv_triggers_alert",
  { data_type => "tinyint", is_nullable => 1 },
  "da_field_template",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "delimiter",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "disallow_overpayment",
  { data_type => "tinyint", is_nullable => 1 },
  "encoding",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "error_detect",
  { data_type => "tinyint", is_nullable => 1 },
  "format_due_date",
  { data_type => "tinyint", is_nullable => 1 },
  "hide_fields",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "holds_block_checkin",
  { data_type => "tinyint", is_nullable => 1 },
  "holds_get_captured",
  { data_type => "tinyint", is_nullable => 1 },
  "inhouse_item_types",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "inhouse_patron_categories",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "login_id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "login_password",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lost_status_for_missing",
  { data_type => "tinyint", is_nullable => 1 },
  "overdues_block_checkout",
  { data_type => "tinyint", is_nullable => 1 },
  "payment_type_writeoff",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "prevcheckout_block_checkout",
  { data_type => "tinyint", is_nullable => 1 },
  "register_id",
  { data_type => "integer", is_nullable => 1 },
  "seen_on_item_information",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "send_patron_home_library_in_af",
  { data_type => "tinyint", is_nullable => 1 },
  "show_checkin_message",
  { data_type => "tinyint", is_nullable => 1 },
  "show_outstanding_amount",
  { data_type => "tinyint", is_nullable => 1 },
  "terminator",
  {
    data_type => "enum",
    extra => { list => ["CR", "CRLF"] },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_account_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_account_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<account_login_id>

=over 4

=item * L</login_id>

=back

=cut

__PACKAGE__->add_unique_constraint("account_login_id", ["login_id"]);

=head1 RELATIONS

=head2 sip_institution

Type: belongs_to

Related object: L<Koha::Schema::Result::SipInstitution>

=cut

__PACKAGE__->belongs_to(
  "sip_institution",
  "Koha::Schema::Result::SipInstitution",
  { sip_institution_id => "sip_institution_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-01-31 15:25:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZyPf+EtRduqZRzWInkTgTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
