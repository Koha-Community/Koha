use utf8;
package Koha::Schema::Result::Aqorder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqorder

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqorders>

=cut

__PACKAGE__->table("aqorders");

=head1 ACCESSORS

=head2 ordernumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 entrydate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 quantity

  data_type: 'smallint'
  is_nullable: 1

=head2 currency

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 listprice

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 datereceived

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 invoiceid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 freight

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 unitprice

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 unitprice_tax_excluded

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 unitprice_tax_included

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 quantityreceived

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 datecancellationprinted

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 cancellationreason

  data_type: 'mediumtext'
  is_nullable: 1

=head2 order_internalnote

  data_type: 'longtext'
  is_nullable: 1

=head2 order_vendornote

  data_type: 'longtext'
  is_nullable: 1

=head2 purchaseordernumber

  data_type: 'longtext'
  is_nullable: 1

=head2 basketno

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 rrp

  data_type: 'decimal'
  is_nullable: 1
  size: [13,2]

=head2 rrp_tax_excluded

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 rrp_tax_included

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 ecost

  data_type: 'decimal'
  is_nullable: 1
  size: [13,2]

=head2 ecost_tax_excluded

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 ecost_tax_included

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 tax_rate_bak

  data_type: 'decimal'
  is_nullable: 1
  size: [6,4]

=head2 tax_rate_on_ordering

  data_type: 'decimal'
  is_nullable: 1
  size: [6,4]

=head2 tax_rate_on_receiving

  data_type: 'decimal'
  is_nullable: 1
  size: [6,4]

=head2 tax_value_bak

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 tax_value_on_ordering

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 tax_value_on_receiving

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 discount

  data_type: 'float'
  is_nullable: 1
  size: [6,4]

=head2 budget_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 budgetdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 sort1

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 sort2

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 sort1_authcat

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 sort2_authcat

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 uncertainprice

  data_type: 'tinyint'
  is_nullable: 1

=head2 claims_count

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 claimed_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 subscriptionid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 parent_ordernumber

  data_type: 'integer'
  is_nullable: 1

=head2 orderstatus

  data_type: 'varchar'
  default_value: 'new'
  is_nullable: 1
  size: 16

=head2 line_item_id

  data_type: 'varchar'
  is_nullable: 1
  size: 35

=head2 suppliers_reference_number

  data_type: 'varchar'
  is_nullable: 1
  size: 35

=head2 suppliers_reference_qualifier

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 suppliers_report

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ordernumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "entrydate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "quantity",
  { data_type => "smallint", is_nullable => 1 },
  "currency",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "listprice",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "datereceived",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "invoiceid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "freight",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "unitprice",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "unitprice_tax_excluded",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "unitprice_tax_included",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "quantityreceived",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "datecancellationprinted",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "cancellationreason",
  { data_type => "mediumtext", is_nullable => 1 },
  "order_internalnote",
  { data_type => "longtext", is_nullable => 1 },
  "order_vendornote",
  { data_type => "longtext", is_nullable => 1 },
  "purchaseordernumber",
  { data_type => "longtext", is_nullable => 1 },
  "basketno",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "rrp",
  { data_type => "decimal", is_nullable => 1, size => [13, 2] },
  "rrp_tax_excluded",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "rrp_tax_included",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "ecost",
  { data_type => "decimal", is_nullable => 1, size => [13, 2] },
  "ecost_tax_excluded",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "ecost_tax_included",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "tax_rate_bak",
  { data_type => "decimal", is_nullable => 1, size => [6, 4] },
  "tax_rate_on_ordering",
  { data_type => "decimal", is_nullable => 1, size => [6, 4] },
  "tax_rate_on_receiving",
  { data_type => "decimal", is_nullable => 1, size => [6, 4] },
  "tax_value_bak",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "tax_value_on_ordering",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "tax_value_on_receiving",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "discount",
  { data_type => "float", is_nullable => 1, size => [6, 4] },
  "budget_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "budgetdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "sort1",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "sort2",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "sort1_authcat",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "sort2_authcat",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "uncertainprice",
  { data_type => "tinyint", is_nullable => 1 },
  "claims_count",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "claimed_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "subscriptionid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "parent_ordernumber",
  { data_type => "integer", is_nullable => 1 },
  "orderstatus",
  {
    data_type => "varchar",
    default_value => "new",
    is_nullable => 1,
    size => 16,
  },
  "line_item_id",
  { data_type => "varchar", is_nullable => 1, size => 35 },
  "suppliers_reference_number",
  { data_type => "varchar", is_nullable => 1, size => 35 },
  "suppliers_reference_qualifier",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "suppliers_report",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ordernumber>

=back

=cut

__PACKAGE__->set_primary_key("ordernumber");

=head1 RELATIONS

=head2 aqorder_users

Type: has_many

Related object: L<Koha::Schema::Result::AqorderUser>

=cut

__PACKAGE__->has_many(
  "aqorder_users",
  "Koha::Schema::Result::AqorderUser",
  { "foreign.ordernumber" => "self.ordernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqorders_items

Type: has_many

Related object: L<Koha::Schema::Result::AqordersItem>

=cut

__PACKAGE__->has_many(
  "aqorders_items",
  "Koha::Schema::Result::AqordersItem",
  { "foreign.ordernumber" => "self.ordernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqorders_transfers_ordernumber_from

Type: might_have

Related object: L<Koha::Schema::Result::AqordersTransfer>

=cut

__PACKAGE__->might_have(
  "aqorders_transfers_ordernumber_from",
  "Koha::Schema::Result::AqordersTransfer",
  { "foreign.ordernumber_from" => "self.ordernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqorders_transfers_ordernumber_to

Type: might_have

Related object: L<Koha::Schema::Result::AqordersTransfer>

=cut

__PACKAGE__->might_have(
  "aqorders_transfers_ordernumber_to",
  "Koha::Schema::Result::AqordersTransfer",
  { "foreign.ordernumber_to" => "self.ordernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 basketno

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbasket>

=cut

__PACKAGE__->belongs_to(
  "basketno",
  "Koha::Schema::Result::Aqbasket",
  { basketno => "basketno" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 budget

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "budget",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "budget_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 currency

Type: belongs_to

Related object: L<Koha::Schema::Result::Currency>

=cut

__PACKAGE__->belongs_to(
  "currency",
  "Koha::Schema::Result::Currency",
  { currency => "currency" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "SET NULL",
  },
);

=head2 invoiceid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqinvoice>

=cut

__PACKAGE__->belongs_to(
  "invoiceid",
  "Koha::Schema::Result::Aqinvoice",
  { invoiceid => "invoiceid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 subscriptionid

Type: belongs_to

Related object: L<Koha::Schema::Result::Subscription>

=cut

__PACKAGE__->belongs_to(
  "subscriptionid",
  "Koha::Schema::Result::Subscription",
  { subscriptionid => "subscriptionid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 borrowernumbers

Type: many_to_many

Composing rels: L</aqorder_users> -> borrowernumber

=cut

__PACKAGE__->many_to_many("borrowernumbers", "aqorder_users", "borrowernumber");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K0GnMGYtZUQ1WCesHKIxHw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
