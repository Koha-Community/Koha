use utf8;
package Koha::Schema::Result::Branch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Branch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<branches>

=cut

__PACKAGE__->table("branches");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 branchname

  data_type: 'mediumtext'
  is_nullable: 0

=head2 branchaddress1

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchaddress2

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchaddress3

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchzip

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 branchcity

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchstate

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchcountry

  data_type: 'text'
  is_nullable: 1

=head2 branchphone

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchfax

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchemail

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchreplyto

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchreturnpath

  data_type: 'mediumtext'
  is_nullable: 1

=head2 branchurl

  data_type: 'mediumtext'
  is_nullable: 1

=head2 issuing

  data_type: 'tinyint'
  is_nullable: 1

=head2 branchip

  data_type: 'varchar'
  is_nullable: 1
  size: 15

=head2 branchprinter

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 branchnotes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 opac_info

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "branchname",
  { data_type => "mediumtext", is_nullable => 0 },
  "branchaddress1",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchaddress2",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchaddress3",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchzip",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "branchcity",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchstate",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchcountry",
  { data_type => "text", is_nullable => 1 },
  "branchphone",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchfax",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchemail",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchreplyto",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchreturnpath",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchurl",
  { data_type => "mediumtext", is_nullable => 1 },
  "issuing",
  { data_type => "tinyint", is_nullable => 1 },
  "branchip",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "branchprinter",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "branchnotes",
  { data_type => "mediumtext", is_nullable => 1 },
  "opac_info",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode");

=head1 RELATIONS

=head2 aqbaskets

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasket>

=cut

__PACKAGE__->has_many(
  "aqbaskets",
  "Koha::Schema::Result::Aqbasket",
  { "foreign.branch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 authorised_values_branches

Type: has_many

Related object: L<Koha::Schema::Result::AuthorisedValuesBranch>

=cut

__PACKAGE__->has_many(
  "authorised_values_branches",
  "Koha::Schema::Result::AuthorisedValuesBranch",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_attribute_types_branches

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerAttributeTypesBranch>

=cut

__PACKAGE__->has_many(
  "borrower_attribute_types_branches",
  "Koha::Schema::Result::BorrowerAttributeTypesBranch",
  { "foreign.b_branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowers

Type: has_many

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->has_many(
  "borrowers",
  "Koha::Schema::Result::Borrower",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branch_borrower_circ_rules

Type: has_many

Related object: L<Koha::Schema::Result::BranchBorrowerCircRule>

=cut

__PACKAGE__->has_many(
  "branch_borrower_circ_rules",
  "Koha::Schema::Result::BranchBorrowerCircRule",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branch_item_rules

Type: has_many

Related object: L<Koha::Schema::Result::BranchItemRule>

=cut

__PACKAGE__->has_many(
  "branch_item_rules",
  "Koha::Schema::Result::BranchItemRule",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branchrelations

Type: has_many

Related object: L<Koha::Schema::Result::Branchrelation>

=cut

__PACKAGE__->has_many(
  "branchrelations",
  "Koha::Schema::Result::Branchrelation",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branchtransfers_frombranches

Type: has_many

Related object: L<Koha::Schema::Result::Branchtransfer>

=cut

__PACKAGE__->has_many(
  "branchtransfers_frombranches",
  "Koha::Schema::Result::Branchtransfer",
  { "foreign.frombranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branchtransfers_tobranches

Type: has_many

Related object: L<Koha::Schema::Result::Branchtransfer>

=cut

__PACKAGE__->has_many(
  "branchtransfers_tobranches",
  "Koha::Schema::Result::Branchtransfer",
  { "foreign.tobranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 categories_branches

Type: has_many

Related object: L<Koha::Schema::Result::CategoriesBranch>

=cut

__PACKAGE__->has_many(
  "categories_branches",
  "Koha::Schema::Result::CategoriesBranch",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 collections

Type: has_many

Related object: L<Koha::Schema::Result::Collection>

=cut

__PACKAGE__->has_many(
  "collections",
  "Koha::Schema::Result::Collection",
  { "foreign.colBranchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 course_items

Type: has_many

Related object: L<Koha::Schema::Result::CourseItem>

=cut

__PACKAGE__->has_many(
  "course_items",
  "Koha::Schema::Result::CourseItem",
  { "foreign.holdingbranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 creator_batches

Type: has_many

Related object: L<Koha::Schema::Result::CreatorBatch>

=cut

__PACKAGE__->has_many(
  "creator_batches",
  "Koha::Schema::Result::CreatorBatch",
  { "foreign.branch_code" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 default_branch_circ_rule

Type: might_have

Related object: L<Koha::Schema::Result::DefaultBranchCircRule>

=cut

__PACKAGE__->might_have(
  "default_branch_circ_rule",
  "Koha::Schema::Result::DefaultBranchCircRule",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 edifact_eans

Type: has_many

Related object: L<Koha::Schema::Result::EdifactEan>

=cut

__PACKAGE__->has_many(
  "edifact_eans",
  "Koha::Schema::Result::EdifactEan",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hold_fill_targets

Type: has_many

Related object: L<Koha::Schema::Result::HoldFillTarget>

=cut

__PACKAGE__->has_many(
  "hold_fill_targets",
  "Koha::Schema::Result::HoldFillTarget",
  { "foreign.source_branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 items_holdingbranches

Type: has_many

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items_holdingbranches",
  "Koha::Schema::Result::Item",
  { "foreign.holdingbranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 items_homebranches

Type: has_many

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items_homebranches",
  "Koha::Schema::Result::Item",
  { "foreign.homebranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 opac_news

Type: has_many

Related object: L<Koha::Schema::Result::OpacNews>

=cut

__PACKAGE__->has_many(
  "opac_news",
  "Koha::Schema::Result::OpacNews",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transport_cost_frombranches

Type: has_many

Related object: L<Koha::Schema::Result::TransportCost>

=cut

__PACKAGE__->has_many(
  "transport_cost_frombranches",
  "Koha::Schema::Result::TransportCost",
  { "foreign.frombranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transport_cost_tobranches

Type: has_many

Related object: L<Koha::Schema::Result::TransportCost>

=cut

__PACKAGE__->has_many(
  "transport_cost_tobranches",
  "Koha::Schema::Result::TransportCost",
  { "foreign.tobranch" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 categorycodes

Type: many_to_many

Composing rels: L</branchrelations> -> categorycode

=cut

__PACKAGE__->many_to_many("categorycodes", "branchrelations", "categorycode");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2014-11-26 11:08:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FjNI9OEpa5OKfwwCkggu0w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
