use utf8;
package Koha::Schema::Result::Aqinvoice;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqinvoice

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqinvoices>

=cut

__PACKAGE__->table("aqinvoices");

=head1 ACCESSORS

=head2 invoiceid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 invoicenumber

  data_type: 'mediumtext'
  is_nullable: 0

=head2 booksellerid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 shipmentdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 billingdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 closedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 shipmentcost

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 shipmentcost_budgetid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 message_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "invoiceid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "invoicenumber",
  { data_type => "mediumtext", is_nullable => 0 },
  "booksellerid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "shipmentdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "billingdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "closedate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "shipmentcost",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "shipmentcost_budgetid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "message_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</invoiceid>

=back

=cut

__PACKAGE__->set_primary_key("invoiceid");

=head1 RELATIONS

=head2 aqorders

Type: has_many

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->has_many(
  "aqorders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.invoiceid" => "self.invoiceid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 booksellerid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "booksellerid",
  "Koha::Schema::Result::Aqbookseller",
  { id => "booksellerid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 message

Type: belongs_to

Related object: L<Koha::Schema::Result::EdifactMessage>

=cut

__PACKAGE__->belongs_to(
  "message",
  "Koha::Schema::Result::EdifactMessage",
  { id => "message_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);

=head2 shipmentcost_budgetid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "shipmentcost_budgetid",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "shipmentcost_budgetid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2014-09-18 16:21:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FPZXlNt8dkjhgt2Rtc+krQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
