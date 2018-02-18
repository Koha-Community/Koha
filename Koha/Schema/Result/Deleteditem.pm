use utf8;
package Koha::Schema::Result::Deleteditem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Deleteditem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<deleteditems>

=cut

__PACKAGE__->table("deleteditems");

=head1 ACCESSORS

=head2 itemnumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 biblioitemnumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 barcode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 dateaccessioned

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 booksellerid

  data_type: 'longtext'
  is_nullable: 1

=head2 homebranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 price

  data_type: 'decimal'
  is_nullable: 1
  size: [8,2]

=head2 replacementprice

  data_type: 'decimal'
  is_nullable: 1
  size: [8,2]

=head2 replacementpricedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 datelastborrowed

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 datelastseen

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 stack

  data_type: 'tinyint'
  is_nullable: 1

=head2 notforloan

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 damaged

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 damaged_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 itemlost

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 itemlost_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 withdrawn

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 withdrawn_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 itemcallnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 coded_location_qualifier

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 issues

  data_type: 'smallint'
  is_nullable: 1

=head2 renewals

  data_type: 'smallint'
  is_nullable: 1

=head2 reserves

  data_type: 'smallint'
  is_nullable: 1

=head2 restricted

  data_type: 'tinyint'
  is_nullable: 1

=head2 itemnotes

  data_type: 'longtext'
  is_nullable: 1

=head2 itemnotes_nonpublic

  data_type: 'longtext'
  is_nullable: 1

=head2 holdingbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 paidfor

  data_type: 'longtext'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 permanent_location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 onloan

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 cn_source

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 cn_sort

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 materials

  data_type: 'mediumtext'
  is_nullable: 1

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 itype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 more_subfields_xml

  data_type: 'longtext'
  is_nullable: 1

=head2 enumchron

  data_type: 'mediumtext'
  is_nullable: 1

=head2 copynumber

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 stocknumber

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 new_status

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "itemnumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "biblioitemnumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "barcode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "dateaccessioned",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "booksellerid",
  { data_type => "longtext", is_nullable => 1 },
  "homebranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "price",
  { data_type => "decimal", is_nullable => 1, size => [8, 2] },
  "replacementprice",
  { data_type => "decimal", is_nullable => 1, size => [8, 2] },
  "replacementpricedate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "datelastborrowed",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "datelastseen",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "stack",
  { data_type => "tinyint", is_nullable => 1 },
  "notforloan",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "damaged",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "damaged_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "itemlost",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "itemlost_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "withdrawn",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "withdrawn_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "itemcallnumber",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "coded_location_qualifier",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "issues",
  { data_type => "smallint", is_nullable => 1 },
  "renewals",
  { data_type => "smallint", is_nullable => 1 },
  "reserves",
  { data_type => "smallint", is_nullable => 1 },
  "restricted",
  { data_type => "tinyint", is_nullable => 1 },
  "itemnotes",
  { data_type => "longtext", is_nullable => 1 },
  "itemnotes_nonpublic",
  { data_type => "longtext", is_nullable => 1 },
  "holdingbranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "paidfor",
  { data_type => "longtext", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "permanent_location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "onloan",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "cn_source",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "cn_sort",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "materials",
  { data_type => "mediumtext", is_nullable => 1 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "itype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "more_subfields_xml",
  { data_type => "longtext", is_nullable => 1 },
  "enumchron",
  { data_type => "mediumtext", is_nullable => 1 },
  "copynumber",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "stocknumber",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "new_status",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</itemnumber>

=back

=cut

__PACKAGE__->set_primary_key("itemnumber");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-18 16:41:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xb11fPjp5PyXU7yfFWHycw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
