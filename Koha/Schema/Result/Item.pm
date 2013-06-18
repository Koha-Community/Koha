package Koha::Schema::Result::Item;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Item

=cut

__PACKAGE__->table("items");

=head1 ACCESSORS

=head2 itemnumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 biblioitemnumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 barcode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 dateaccessioned

  data_type: 'date'
  is_nullable: 1

=head2 booksellerid

  data_type: 'mediumtext'
  is_nullable: 1

=head2 homebranch

  data_type: 'varchar'
  is_foreign_key: 1
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
  is_nullable: 1

=head2 datelastborrowed

  data_type: 'date'
  is_nullable: 1

=head2 datelastseen

  data_type: 'date'
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

=head2 itemlost

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 wthdrawn

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

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

  data_type: 'mediumtext'
  is_nullable: 1

=head2 holdingbranch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 paidfor

  data_type: 'mediumtext'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
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
  is_nullable: 1

=head2 cn_source

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 cn_sort

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 materials

  data_type: 'text'
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

  data_type: 'text'
  is_nullable: 1

=head2 copynumber

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 stocknumber

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "itemnumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "biblioitemnumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "barcode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "dateaccessioned",
  { data_type => "date", is_nullable => 1 },
  "booksellerid",
  { data_type => "mediumtext", is_nullable => 1 },
  "homebranch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "price",
  { data_type => "decimal", is_nullable => 1, size => [8, 2] },
  "replacementprice",
  { data_type => "decimal", is_nullable => 1, size => [8, 2] },
  "replacementpricedate",
  { data_type => "date", is_nullable => 1 },
  "datelastborrowed",
  { data_type => "date", is_nullable => 1 },
  "datelastseen",
  { data_type => "date", is_nullable => 1 },
  "stack",
  { data_type => "tinyint", is_nullable => 1 },
  "notforloan",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "damaged",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "itemlost",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "wthdrawn",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
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
  { data_type => "mediumtext", is_nullable => 1 },
  "holdingbranch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "paidfor",
  { data_type => "mediumtext", is_nullable => 1 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "permanent_location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "onloan",
  { data_type => "date", is_nullable => 1 },
  "cn_source",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "cn_sort",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "materials",
  { data_type => "text", is_nullable => 1 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "itype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "more_subfields_xml",
  { data_type => "longtext", is_nullable => 1 },
  "enumchron",
  { data_type => "text", is_nullable => 1 },
  "copynumber",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "stocknumber",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);
__PACKAGE__->set_primary_key("itemnumber");
__PACKAGE__->add_unique_constraint("itembarcodeidx", ["barcode"]);

=head1 RELATIONS

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branchtransfers

Type: has_many

Related object: L<Koha::Schema::Result::Branchtransfer>

=cut

__PACKAGE__->has_many(
  "branchtransfers",
  "Koha::Schema::Result::Branchtransfer",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 course_item

Type: might_have

Related object: L<Koha::Schema::Result::CourseItem>

=cut

__PACKAGE__->might_have(
  "course_item",
  "Koha::Schema::Result::CourseItem",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 creator_batches

Type: has_many

Related object: L<Koha::Schema::Result::CreatorBatch>

=cut

__PACKAGE__->has_many(
  "creator_batches",
  "Koha::Schema::Result::CreatorBatch",
  { "foreign.item_number" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hold_fill_target

Type: might_have

Related object: L<Koha::Schema::Result::HoldFillTarget>

=cut

__PACKAGE__->might_have(
  "hold_fill_target",
  "Koha::Schema::Result::HoldFillTarget",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 issues

Type: has_many

Related object: L<Koha::Schema::Result::Issue>

=cut

__PACKAGE__->has_many(
  "issues",
  "Koha::Schema::Result::Issue",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biblioitemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblioitem>

=cut

__PACKAGE__->belongs_to(
  "biblioitemnumber",
  "Koha::Schema::Result::Biblioitem",
  { biblioitemnumber => "biblioitemnumber" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 homebranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "homebranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "homebranch" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 holdingbranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "holdingbranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "holdingbranch" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 old_issues

Type: has_many

Related object: L<Koha::Schema::Result::OldIssue>

=cut

__PACKAGE__->has_many(
  "old_issues",
  "Koha::Schema::Result::OldIssue",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 serialitem

Type: might_have

Related object: L<Koha::Schema::Result::Serialitem>

=cut

__PACKAGE__->might_have(
  "serialitem",
  "Koha::Schema::Result::Serialitem",
  { "foreign.itemnumber" => "self.itemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f3HngbnArIKegakzHgcFBg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
