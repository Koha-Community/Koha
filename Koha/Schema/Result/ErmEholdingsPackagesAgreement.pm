use utf8;
package Koha::Schema::Result::ErmEholdingsPackagesAgreement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmEholdingsPackagesAgreement

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_eholdings_packages_agreements>

=cut

__PACKAGE__->table("erm_eholdings_packages_agreements");

=head1 ACCESSORS

=head2 package_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the package

=head2 agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the agreement

=cut

__PACKAGE__->add_columns(
  "package_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</package_id>

=item * L</agreement_id>

=back

=cut

__PACKAGE__->set_primary_key("package_id", "agreement_id");

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

=head2 package

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmEholdingsPackage>

=cut

__PACKAGE__->belongs_to(
  "package",
  "Koha::Schema::Result::ErmEholdingsPackage",
  { package_id => "package_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-11 11:52:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3nCckFzWVD8oZCG6eoljxw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ERM::EHoldings::Package::Agreement';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ERM::EHoldings::Package::Agreements';
}

1;
