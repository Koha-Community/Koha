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

a unique key assigned to each branch

=head2 branchname

  data_type: 'longtext'
  is_nullable: 0

the name of your library or branch

=head2 branchaddress1

  data_type: 'longtext'
  is_nullable: 1

the first address line of for your library or branch

=head2 branchaddress2

  data_type: 'longtext'
  is_nullable: 1

the second address line of for your library or branch

=head2 branchaddress3

  data_type: 'longtext'
  is_nullable: 1

the third address line of for your library or branch

=head2 branchzip

  data_type: 'varchar'
  is_nullable: 1
  size: 25

the zip or postal code for your library or branch

=head2 branchcity

  data_type: 'longtext'
  is_nullable: 1

the city or province for your library or branch

=head2 branchstate

  data_type: 'longtext'
  is_nullable: 1

the state for your library or branch

=head2 branchcountry

  data_type: 'mediumtext'
  is_nullable: 1

the county for your library or branch

=head2 branchphone

  data_type: 'longtext'
  is_nullable: 1

the primary phone for your library or branch

=head2 branchfax

  data_type: 'longtext'
  is_nullable: 1

the fax number for your library or branch

=head2 branchemail

  data_type: 'longtext'
  is_nullable: 1

the primary email address for your library or branch

=head2 branchillemail

  data_type: 'longtext'
  is_nullable: 1

the ILL staff email address for your library or branch

=head2 branchreplyto

  data_type: 'longtext'
  is_nullable: 1

the email to be used as a Reply-To

=head2 branchreturnpath

  data_type: 'longtext'
  is_nullable: 1

the email to be used as Return-Path

=head2 branchurl

  data_type: 'longtext'
  is_nullable: 1

the URL for your library or branch's website

=head2 issuing

  data_type: 'tinyint'
  is_nullable: 1

unused in Koha

=head2 branchip

  data_type: 'varchar'
  is_nullable: 1
  size: 15

the IP address for your library or branch

=head2 branchnotes

  data_type: 'longtext'
  is_nullable: 1

notes related to your library or branch

=head2 geolocation

  data_type: 'varchar'
  is_nullable: 1
  size: 255

geolocation of your library

=head2 marcorgcode

  data_type: 'varchar'
  is_nullable: 1
  size: 16

MARC Organization Code, see http://www.loc.gov/marc/organizations/orgshome.html, when empty defaults to syspref MARCOrgCode

=head2 pickup_location

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

the ability to act as a pickup location

=head2 public

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

whether this library should show in the opac

=cut

__PACKAGE__->add_columns(
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "branchname",
  { data_type => "longtext", is_nullable => 0 },
  "branchaddress1",
  { data_type => "longtext", is_nullable => 1 },
  "branchaddress2",
  { data_type => "longtext", is_nullable => 1 },
  "branchaddress3",
  { data_type => "longtext", is_nullable => 1 },
  "branchzip",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "branchcity",
  { data_type => "longtext", is_nullable => 1 },
  "branchstate",
  { data_type => "longtext", is_nullable => 1 },
  "branchcountry",
  { data_type => "mediumtext", is_nullable => 1 },
  "branchphone",
  { data_type => "longtext", is_nullable => 1 },
  "branchfax",
  { data_type => "longtext", is_nullable => 1 },
  "branchemail",
  { data_type => "longtext", is_nullable => 1 },
  "branchillemail",
  { data_type => "longtext", is_nullable => 1 },
  "branchreplyto",
  { data_type => "longtext", is_nullable => 1 },
  "branchreturnpath",
  { data_type => "longtext", is_nullable => 1 },
  "branchurl",
  { data_type => "longtext", is_nullable => 1 },
  "issuing",
  { data_type => "tinyint", is_nullable => 1 },
  "branchip",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "branchnotes",
  { data_type => "longtext", is_nullable => 1 },
  "geolocation",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "marcorgcode",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "pickup_location",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "public",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode");

=head1 RELATIONS

=head2 account_credit_types_branches

Type: has_many

Related object: L<Koha::Schema::Result::AccountCreditTypesBranch>

=cut

__PACKAGE__->has_many(
  "account_credit_types_branches",
  "Koha::Schema::Result::AccountCreditTypesBranch",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 account_debit_types_branches

Type: has_many

Related object: L<Koha::Schema::Result::AccountDebitTypesBranch>

=cut

__PACKAGE__->has_many(
  "account_debit_types_branches",
  "Koha::Schema::Result::AccountDebitTypesBranch",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 additional_contents

Type: has_many

Related object: L<Koha::Schema::Result::AdditionalContent>

=cut

__PACKAGE__->has_many(
  "additional_contents",
  "Koha::Schema::Result::AdditionalContent",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 article_requests

Type: has_many

Related object: L<Koha::Schema::Result::ArticleRequest>

=cut

__PACKAGE__->has_many(
  "article_requests",
  "Koha::Schema::Result::ArticleRequest",
  { "foreign.branchcode" => "self.branchcode" },
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

=head2 branches_overdrive

Type: might_have

Related object: L<Koha::Schema::Result::BranchesOverdrive>

=cut

__PACKAGE__->might_have(
  "branches_overdrive",
  "Koha::Schema::Result::BranchesOverdrive",
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

=head2 cash_registers

Type: has_many

Related object: L<Koha::Schema::Result::CashRegister>

=cut

__PACKAGE__->has_many(
  "cash_registers",
  "Koha::Schema::Result::CashRegister",
  { "foreign.branch" => "self.branchcode" },
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

=head2 circulation_rules

Type: has_many

Related object: L<Koha::Schema::Result::CirculationRule>

=cut

__PACKAGE__->has_many(
  "circulation_rules",
  "Koha::Schema::Result::CirculationRule",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 club_enrollments

Type: has_many

Related object: L<Koha::Schema::Result::ClubEnrollment>

=cut

__PACKAGE__->has_many(
  "club_enrollments",
  "Koha::Schema::Result::ClubEnrollment",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 club_templates

Type: has_many

Related object: L<Koha::Schema::Result::ClubTemplate>

=cut

__PACKAGE__->has_many(
  "club_templates",
  "Koha::Schema::Result::ClubTemplate",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 clubs

Type: has_many

Related object: L<Koha::Schema::Result::Club>

=cut

__PACKAGE__->has_many(
  "clubs",
  "Koha::Schema::Result::Club",
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

=head2 course_items_homebranch_storages

Type: has_many

Related object: L<Koha::Schema::Result::CourseItem>

=cut

__PACKAGE__->has_many(
  "course_items_homebranch_storages",
  "Koha::Schema::Result::CourseItem",
  { "foreign.homebranch_storage" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 course_items_homebranches

Type: has_many

Related object: L<Koha::Schema::Result::CourseItem>

=cut

__PACKAGE__->has_many(
  "course_items_homebranches",
  "Koha::Schema::Result::CourseItem",
  { "foreign.homebranch" => "self.branchcode" },
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

=head2 curbside_pickup_policy

Type: might_have

Related object: L<Koha::Schema::Result::CurbsidePickupPolicy>

=cut

__PACKAGE__->might_have(
  "curbside_pickup_policy",
  "Koha::Schema::Result::CurbsidePickupPolicy",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 curbside_pickups

Type: has_many

Related object: L<Koha::Schema::Result::CurbsidePickup>

=cut

__PACKAGE__->has_many(
  "curbside_pickups",
  "Koha::Schema::Result::CurbsidePickup",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 desks

Type: has_many

Related object: L<Koha::Schema::Result::Desk>

=cut

__PACKAGE__->has_many(
  "desks",
  "Koha::Schema::Result::Desk",
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

=head2 identity_provider_domains

Type: has_many

Related object: L<Koha::Schema::Result::IdentityProviderDomain>

=cut

__PACKAGE__->has_many(
  "identity_provider_domains",
  "Koha::Schema::Result::IdentityProviderDomain",
  { "foreign.default_library_id" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 illbatches

Type: has_many

Related object: L<Koha::Schema::Result::Illbatch>

=cut

__PACKAGE__->has_many(
  "illbatches",
  "Koha::Schema::Result::Illbatch",
  { "foreign.library_id" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 illrequests

Type: has_many

Related object: L<Koha::Schema::Result::Illrequest>

=cut

__PACKAGE__->has_many(
  "illrequests",
  "Koha::Schema::Result::Illrequest",
  { "foreign.branchcode" => "self.branchcode" },
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

=head2 itemtypes_branches

Type: has_many

Related object: L<Koha::Schema::Result::ItemtypesBranch>

=cut

__PACKAGE__->has_many(
  "itemtypes_branches",
  "Koha::Schema::Result::ItemtypesBranch",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 library_groups

Type: has_many

Related object: L<Koha::Schema::Result::LibraryGroup>

=cut

__PACKAGE__->has_many(
  "library_groups",
  "Koha::Schema::Result::LibraryGroup",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 library_smtp_server

Type: might_have

Related object: L<Koha::Schema::Result::LibrarySmtpServer>

=cut

__PACKAGE__->might_have(
  "library_smtp_server",
  "Koha::Schema::Result::LibrarySmtpServer",
  { "foreign.library_id" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 problem_reports

Type: has_many

Related object: L<Koha::Schema::Result::ProblemReport>

=cut

__PACKAGE__->has_many(
  "problem_reports",
  "Koha::Schema::Result::ProblemReport",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 recalls

Type: has_many

Related object: L<Koha::Schema::Result::Recall>

=cut

__PACKAGE__->has_many(
  "recalls",
  "Koha::Schema::Result::Recall",
  { "foreign.pickup_library_id" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 repeatable_holidays

Type: has_many

Related object: L<Koha::Schema::Result::RepeatableHoliday>

=cut

__PACKAGE__->has_many(
  "repeatable_holidays",
  "Koha::Schema::Result::RepeatableHoliday",
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

=head2 special_holidays

Type: has_many

Related object: L<Koha::Schema::Result::SpecialHoliday>

=cut

__PACKAGE__->has_many(
  "special_holidays",
  "Koha::Schema::Result::SpecialHoliday",
  { "foreign.branchcode" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 stockrotationstages

Type: has_many

Related object: L<Koha::Schema::Result::Stockrotationstage>

=cut

__PACKAGE__->has_many(
  "stockrotationstages",
  "Koha::Schema::Result::Stockrotationstage",
  { "foreign.branchcode_id" => "self.branchcode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 suggestions

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions",
  "Koha::Schema::Result::Suggestion",
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-10 14:16:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LjdauIP6C1I1/1liCIddJQ

__PACKAGE__->add_columns(
    '+pickup_location' => { is_boolean => 1 },
    '+public'          => { is_boolean => 1 }
);

sub koha_object_class {
    'Koha::Library';
}
sub koha_objects_class {
    'Koha::Libraries';
}

1;
