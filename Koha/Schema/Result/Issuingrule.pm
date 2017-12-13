use utf8;
package Koha::Schema::Result::Issuingrule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Issuingrule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<issuingrules>

=cut

__PACKAGE__->table("issuingrules");

=head1 ACCESSORS

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 itemtype

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 restrictedtype

  data_type: 'tinyint'
  is_nullable: 1

=head2 rentaldiscount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 reservecharge

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 fine

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 finedays

  data_type: 'integer'
  is_nullable: 1

=head2 maxsuspensiondays

  data_type: 'integer'
  is_nullable: 1

=head2 suspension_chargeperiod

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 firstremind

  data_type: 'integer'
  is_nullable: 1

=head2 chargeperiod

  data_type: 'integer'
  is_nullable: 1

=head2 chargeperiod_charge_at

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 accountsent

  data_type: 'integer'
  is_nullable: 1

=head2 chargename

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 maxissueqty

  data_type: 'integer'
  is_nullable: 1

=head2 maxonsiteissueqty

  data_type: 'integer'
  is_nullable: 1

=head2 issuelength

  data_type: 'integer'
  is_nullable: 1

=head2 lengthunit

  data_type: 'varchar'
  default_value: 'days'
  is_nullable: 1
  size: 10

=head2 hardduedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 hardduedatecompare

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 renewalsallowed

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 renewalperiod

  data_type: 'integer'
  is_nullable: 1

=head2 norenewalbefore

  data_type: 'integer'
  is_nullable: 1

=head2 auto_renew

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 no_auto_renewal_after

  data_type: 'integer'
  is_nullable: 1

=head2 no_auto_renewal_after_hard_limit

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 reservesallowed

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 holds_per_record

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 overduefinescap

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 cap_fine_to_replacement_price

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 onshelfholds

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 opacitemholds

  data_type: 'char'
  default_value: 'N'
  is_nullable: 0
  size: 1

=head2 article_requests

  data_type: 'enum'
  default_value: 'no'
  extra: {list => ["no","yes","bib_only","item_only"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "categorycode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "itemtype",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "restrictedtype",
  { data_type => "tinyint", is_nullable => 1 },
  "rentaldiscount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "reservecharge",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "fine",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "finedays",
  { data_type => "integer", is_nullable => 1 },
  "maxsuspensiondays",
  { data_type => "integer", is_nullable => 1 },
  "suspension_chargeperiod",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "firstremind",
  { data_type => "integer", is_nullable => 1 },
  "chargeperiod",
  { data_type => "integer", is_nullable => 1 },
  "chargeperiod_charge_at",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "accountsent",
  { data_type => "integer", is_nullable => 1 },
  "chargename",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "maxissueqty",
  { data_type => "integer", is_nullable => 1 },
  "maxonsiteissueqty",
  { data_type => "integer", is_nullable => 1 },
  "issuelength",
  { data_type => "integer", is_nullable => 1 },
  "lengthunit",
  {
    data_type => "varchar",
    default_value => "days",
    is_nullable => 1,
    size => 10,
  },
  "hardduedate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "hardduedatecompare",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "renewalsallowed",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "renewalperiod",
  { data_type => "integer", is_nullable => 1 },
  "norenewalbefore",
  { data_type => "integer", is_nullable => 1 },
  "auto_renew",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "no_auto_renewal_after",
  { data_type => "integer", is_nullable => 1 },
  "no_auto_renewal_after_hard_limit",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "reservesallowed",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "holds_per_record",
  { data_type => "smallint", default_value => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "overduefinescap",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "cap_fine_to_replacement_price",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "onshelfholds",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "opacitemholds",
  { data_type => "char", default_value => "N", is_nullable => 0, size => 1 },
  "article_requests",
  {
    data_type => "enum",
    default_value => "no",
    extra => { list => ["no", "yes", "bib_only", "item_only"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=item * L</categorycode>

=item * L</itemtype>

=back

=cut

__PACKAGE__->set_primary_key("branchcode", "categorycode", "itemtype");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-12-13 12:44:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VBD8atc/D/6rN0D+aTaSOQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
