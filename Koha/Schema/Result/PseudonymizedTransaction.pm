use utf8;
package Koha::Schema::Result::PseudonymizedTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PseudonymizedTransaction

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<pseudonymized_transactions>

=cut

__PACKAGE__->table("pseudonymized_transactions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 hashed_borrowernumber

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=head2 has_cardnumber

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 title

  data_type: 'longtext'
  is_nullable: 1

=head2 city

  data_type: 'longtext'
  is_nullable: 1

=head2 state

  data_type: 'mediumtext'
  is_nullable: 1

=head2 zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 country

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 dateenrolled

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 sex

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 sort1

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 sort2

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 datetime

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 transaction_branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 transaction_type

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 1

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 holdingbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 homebranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 itemcallnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "hashed_borrowernumber",
  { data_type => "varchar", is_nullable => 0, size => 60 },
  "has_cardnumber",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "title",
  { data_type => "longtext", is_nullable => 1 },
  "city",
  { data_type => "longtext", is_nullable => 1 },
  "state",
  { data_type => "mediumtext", is_nullable => 1 },
  "zipcode",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "country",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "categorycode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "dateenrolled",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "sex",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "sort1",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "sort2",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "datetime",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "transaction_branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "transaction_type",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "itemnumber",
  { data_type => "integer", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "holdingbranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "homebranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "itemcallnumber",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 pseudonymized_borrower_attributes

Type: has_many

Related object: L<Koha::Schema::Result::PseudonymizedBorrowerAttribute>

=cut

__PACKAGE__->has_many(
  "pseudonymized_borrower_attributes",
  "Koha::Schema::Result::PseudonymizedBorrowerAttribute",
  { "foreign.transaction_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-11-19 14:20:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GVTIlyIi8Vquhf662tDmsQ

__PACKAGE__->add_columns(
    '+has_cardnumber' => { is_boolean => 1 },
);

1;
