use utf8;
package Koha::Schema::Result::ErmAgreementLicense;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmAgreementLicense

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_agreement_licenses>

=cut

__PACKAGE__->table("erm_agreement_licenses");

=head1 ACCESSORS

=head2 agreement_license_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the agreement

=head2 license_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the license

=head2 status

  data_type: 'varchar'
  is_nullable: 0
  size: 80

current status of the license

=head2 physical_location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

physical location of the license

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

notes about this license

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

URI of the license

=cut

__PACKAGE__->add_columns(
  "agreement_license_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "license_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "status",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "physical_location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</agreement_license_id>

=back

=cut

__PACKAGE__->set_primary_key("agreement_license_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<erm_agreement_licenses_uniq>

=over 4

=item * L</agreement_id>

=item * L</license_id>

=back

=cut

__PACKAGE__->add_unique_constraint("erm_agreement_licenses_uniq", ["agreement_id", "license_id"]);

=head1 RELATIONS

=head2 agreement

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->belongs_to(
  "agreement",
  "Koha::Schema::Result::ErmAgreement",
  { agreement_id => "agreement_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 license

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmLicense>

=cut

__PACKAGE__->belongs_to(
  "license",
  "Koha::Schema::Result::ErmLicense",
  { license_id => "license_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-20 08:58:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pO0QPWFMSap1XER+0hdEqg

sub koha_object_class {
    'Koha::ERM::Agreement::License';
}
sub koha_objects_class {
    'Koha::ERM::Agreement::Licenses';
}

1;
