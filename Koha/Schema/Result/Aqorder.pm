package Koha::Schema::Result::Aqorder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Aqorder

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
  is_nullable: 1

=head2 quantity

  data_type: 'smallint'
  is_nullable: 1

=head2 currency

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 listprice

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 totalamount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 datereceived

  data_type: 'date'
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

=head2 quantityreceived

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 cancelledby

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 datecancellationprinted

  data_type: 'date'
  is_nullable: 1

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 supplierreference

  data_type: 'mediumtext'
  is_nullable: 1

=head2 purchaseordernumber

  data_type: 'mediumtext'
  is_nullable: 1

=head2 basketno

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 biblioitemnumber

  data_type: 'integer'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 rrp

  data_type: 'decimal'
  is_nullable: 1
  size: [13,2]

=head2 ecost

  data_type: 'decimal'
  is_nullable: 1
  size: [13,2]

=head2 gstrate

  data_type: 'decimal'
  is_nullable: 1
  size: [6,4]

=head2 discount

  data_type: 'float'
  is_nullable: 1
  size: [6,4]

=head2 budget_id

  data_type: 'integer'
  is_nullable: 0

=head2 budgetgroup_id

  data_type: 'integer'
  is_nullable: 0

=head2 budgetdate

  data_type: 'date'
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
  is_nullable: 1

=head2 subscriptionid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 parent_ordernumber

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ordernumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "entrydate",
  { data_type => "date", is_nullable => 1 },
  "quantity",
  { data_type => "smallint", is_nullable => 1 },
  "currency",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "listprice",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "totalamount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "datereceived",
  { data_type => "date", is_nullable => 1 },
  "invoiceid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "freight",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "unitprice",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "quantityreceived",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "cancelledby",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "datecancellationprinted",
  { data_type => "date", is_nullable => 1 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "supplierreference",
  { data_type => "mediumtext", is_nullable => 1 },
  "purchaseordernumber",
  { data_type => "mediumtext", is_nullable => 1 },
  "basketno",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "biblioitemnumber",
  { data_type => "integer", is_nullable => 1 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "rrp",
  { data_type => "decimal", is_nullable => 1, size => [13, 2] },
  "ecost",
  { data_type => "decimal", is_nullable => 1, size => [13, 2] },
  "gstrate",
  { data_type => "decimal", is_nullable => 1, size => [6, 4] },
  "discount",
  { data_type => "float", is_nullable => 1, size => [6, 4] },
  "budget_id",
  { data_type => "integer", is_nullable => 0 },
  "budgetgroup_id",
  { data_type => "integer", is_nullable => 0 },
  "budgetdate",
  { data_type => "date", is_nullable => 1 },
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
  { data_type => "date", is_nullable => 1 },
  "subscriptionid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "parent_ordernumber",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("ordernumber");

=head1 RELATIONS

=head2 basketno

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbasket>

=cut

__PACKAGE__->belongs_to(
  "basketno",
  "Koha::Schema::Result::Aqbasket",
  { basketno => "basketno" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 invoiceid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqinvoice>

=cut

__PACKAGE__->belongs_to(
  "invoiceid",
  "Koha::Schema::Result::Aqinvoice",
  { invoiceid => "invoiceid" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 subscriptionid

Type: belongs_to

Related object: L<Koha::Schema::Result::Subscription>

=cut

__PACKAGE__->belongs_to(
  "subscriptionid",
  "Koha::Schema::Result::Subscription",
  { subscriptionid => "subscriptionid" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H1fME9Sli2LWh6zAmpzK8A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
