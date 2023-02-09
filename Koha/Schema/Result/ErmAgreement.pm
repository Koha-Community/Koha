use utf8;
package Koha::Schema::Result::ErmAgreement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmAgreement

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_agreements>

=cut

__PACKAGE__->table("erm_agreements");

=head1 ACCESSORS

=head2 agreement_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key to aqbooksellers

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

name of the agreement

=head2 description

  data_type: 'longtext'
  is_nullable: 1

description of the agreement

=head2 status

  data_type: 'varchar'
  is_nullable: 0
  size: 80

current status of the agreement

=head2 closure_reason

  data_type: 'varchar'
  is_nullable: 1
  size: 80

reason of the closure

=head2 is_perpetual

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

is the agreement perpetual

=head2 renewal_priority

  data_type: 'varchar'
  is_nullable: 1
  size: 80

priority of the renewal

=head2 license_info

  data_type: 'varchar'
  is_nullable: 1
  size: 80

info about the license

=cut

__PACKAGE__->add_columns(
  "agreement_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "status",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "closure_reason",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "is_perpetual",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "renewal_priority",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "license_info",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</agreement_id>

=back

=cut

__PACKAGE__->set_primary_key("agreement_id");

=head1 RELATIONS

=head2 erm_agreement_licenses

Type: has_many

Related object: L<Koha::Schema::Result::ErmAgreementLicense>

=cut

__PACKAGE__->has_many(
  "erm_agreement_licenses",
  "Koha::Schema::Result::ErmAgreementLicense",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_agreement_periods

Type: has_many

Related object: L<Koha::Schema::Result::ErmAgreementPeriod>

=cut

__PACKAGE__->has_many(
  "erm_agreement_periods",
  "Koha::Schema::Result::ErmAgreementPeriod",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_agreement_relationships_agreements

Type: has_many

Related object: L<Koha::Schema::Result::ErmAgreementRelationship>

=cut

__PACKAGE__->has_many(
  "erm_agreement_relationships_agreements",
  "Koha::Schema::Result::ErmAgreementRelationship",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_agreement_relationships_related_agreements

Type: has_many

Related object: L<Koha::Schema::Result::ErmAgreementRelationship>

=cut

__PACKAGE__->has_many(
  "erm_agreement_relationships_related_agreements",
  "Koha::Schema::Result::ErmAgreementRelationship",
  { "foreign.related_agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_documents

Type: has_many

Related object: L<Koha::Schema::Result::ErmDocument>

=cut

__PACKAGE__->has_many(
  "erm_documents",
  "Koha::Schema::Result::ErmDocument",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_eholdings_packages_agreements

Type: has_many

Related object: L<Koha::Schema::Result::ErmEholdingsPackagesAgreement>

=cut

__PACKAGE__->has_many(
  "erm_eholdings_packages_agreements",
  "Koha::Schema::Result::ErmEholdingsPackagesAgreement",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_user_roles

Type: has_many

Related object: L<Koha::Schema::Result::ErmUserRole>

=cut

__PACKAGE__->has_many(
  "erm_user_roles",
  "Koha::Schema::Result::ErmUserRole",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 packages

Type: many_to_many

Composing rels: L</erm_eholdings_packages_agreements> -> package

=cut

__PACKAGE__->many_to_many("packages", "erm_eholdings_packages_agreements", "package");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-11 11:52:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N93LnvdKirtuV6BSrTGzVg

__PACKAGE__->has_many(
  "user_roles",
  "Koha::Schema::Result::ErmUserRole",
  { "foreign.agreement_id" => "self.agreement_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    '+is_perpetual' => { is_boolean => 1 }
);

sub koha_object_class {
    'Koha::ERM::Agreement';
}
sub koha_objects_class {
    'Koha::ERM::Agreements';
}

1;
