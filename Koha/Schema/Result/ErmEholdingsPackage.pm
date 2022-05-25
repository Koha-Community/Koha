use utf8;
package Koha::Schema::Result::ErmEholdingsPackage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmEholdingsPackage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_eholdings_packages>

=cut

__PACKAGE__->table("erm_eholdings_packages");

=head1 ACCESSORS

=head2 package_id

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

name of the package

=head2 external_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

External key

=head2 provider

  data_type: 'enum'
  extra: {list => ["ebsco"]}
  is_nullable: 1

External provider

=head2 package_type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

type of the package

=head2 content_type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

type of the package

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

notes about this package

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date of creation of the package

=cut

__PACKAGE__->add_columns(
  "package_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "external_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "provider",
  { data_type => "enum", extra => { list => ["ebsco"] }, is_nullable => 1 },
  "package_type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "content_type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</package_id>

=back

=cut

__PACKAGE__->set_primary_key("package_id");

=head1 RELATIONS

=head2 erm_eholdings_packages_agreements

Type: has_many

Related object: L<Koha::Schema::Result::ErmEholdingsPackagesAgreement>

=cut

__PACKAGE__->has_many(
  "erm_eholdings_packages_agreements",
  "Koha::Schema::Result::ErmEholdingsPackagesAgreement",
  { "foreign.package_id" => "self.package_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_eholdings_resources

Type: has_many

Related object: L<Koha::Schema::Result::ErmEholdingsResource>

=cut

__PACKAGE__->has_many(
  "erm_eholdings_resources",
  "Koha::Schema::Result::ErmEholdingsResource",
  { "foreign.package_id" => "self.package_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-19 09:25:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KbZxONSm/pxXvUFi3PuZiQ

sub koha_object_class {
    'Koha::ERM::EHoldings::Package';
}
sub koha_objects_class {
    'Koha::ERM::EHoldings::Packages';
}

1;
