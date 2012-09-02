package Koha::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Category

=cut

__PACKAGE__->table("categories");

=head1 ACCESSORS

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 enrolmentperiod

  data_type: 'smallint'
  is_nullable: 1

=head2 enrolmentperioddate

  data_type: 'date'
  is_nullable: 1

=head2 upperagelimit

  data_type: 'smallint'
  is_nullable: 1

=head2 dateofbirthrequired

  data_type: 'tinyint'
  is_nullable: 1

=head2 finetype

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 bulk

  data_type: 'tinyint'
  is_nullable: 1

=head2 enrolmentfee

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 overduenoticerequired

  data_type: 'tinyint'
  is_nullable: 1

=head2 issuelimit

  data_type: 'smallint'
  is_nullable: 1

=head2 reservefee

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 hidelostitems

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 category_type

  data_type: 'varchar'
  default_value: 'A'
  is_nullable: 0
  size: 1

=cut

__PACKAGE__->add_columns(
  "categorycode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "enrolmentperiod",
  { data_type => "smallint", is_nullable => 1 },
  "enrolmentperioddate",
  { data_type => "date", is_nullable => 1 },
  "upperagelimit",
  { data_type => "smallint", is_nullable => 1 },
  "dateofbirthrequired",
  { data_type => "tinyint", is_nullable => 1 },
  "finetype",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "bulk",
  { data_type => "tinyint", is_nullable => 1 },
  "enrolmentfee",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "overduenoticerequired",
  { data_type => "tinyint", is_nullable => 1 },
  "issuelimit",
  { data_type => "smallint", is_nullable => 1 },
  "reservefee",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "hidelostitems",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "category_type",
  { data_type => "varchar", default_value => "A", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("categorycode");

=head1 RELATIONS

=head2 borrower_attribute_types

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerAttributeType>

=cut

__PACKAGE__->has_many(
  "borrower_attribute_types",
  "Koha::Schema::Result::BorrowerAttributeType",
  { "foreign.category_code" => "self.categorycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_message_preferences

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerMessagePreference>

=cut

__PACKAGE__->has_many(
  "borrower_message_preferences",
  "Koha::Schema::Result::BorrowerMessagePreference",
  { "foreign.categorycode" => "self.categorycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowers

Type: has_many

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->has_many(
  "borrowers",
  "Koha::Schema::Result::Borrower",
  { "foreign.categorycode" => "self.categorycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branch_borrower_circ_rules

Type: has_many

Related object: L<Koha::Schema::Result::BranchBorrowerCircRule>

=cut

__PACKAGE__->has_many(
  "branch_borrower_circ_rules",
  "Koha::Schema::Result::BranchBorrowerCircRule",
  { "foreign.categorycode" => "self.categorycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 default_borrower_circ_rule

Type: might_have

Related object: L<Koha::Schema::Result::DefaultBorrowerCircRule>

=cut

__PACKAGE__->might_have(
  "default_borrower_circ_rule",
  "Koha::Schema::Result::DefaultBorrowerCircRule",
  { "foreign.categorycode" => "self.categorycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BpTckQJaDAxGwrOS9s3tuQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
