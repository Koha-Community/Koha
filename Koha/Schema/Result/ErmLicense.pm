use utf8;
package Koha::Schema::Result::ErmLicense;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmLicense

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_licenses>

=cut

__PACKAGE__->table("erm_licenses");

=head1 ACCESSORS

=head2 license_id

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

name of the license

=head2 description

  data_type: 'longtext'
  is_nullable: 1

description of the license

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 80

type of the license

=head2 status

  data_type: 'varchar'
  is_nullable: 0
  size: 80

current status of the license

=head2 started_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

start of the license

=head2 ended_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

end of the license

=cut

__PACKAGE__->add_columns(
  "license_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "status",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "started_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "ended_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</license_id>

=back

=cut

__PACKAGE__->set_primary_key("license_id");

=head1 RELATIONS

=head2 erm_agreement_licenses

Type: has_many

Related object: L<Koha::Schema::Result::ErmAgreementLicense>

=cut

__PACKAGE__->has_many(
  "erm_agreement_licenses",
  "Koha::Schema::Result::ErmAgreementLicense",
  { "foreign.license_id" => "self.license_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_documents

Type: has_many

Related object: L<Koha::Schema::Result::ErmDocument>

=cut

__PACKAGE__->has_many(
  "erm_documents",
  "Koha::Schema::Result::ErmDocument",
  { "foreign.license_id" => "self.license_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_user_roles

Type: has_many

Related object: L<Koha::Schema::Result::ErmUserRole>

=cut

__PACKAGE__->has_many(
  "erm_user_roles",
  "Koha::Schema::Result::ErmUserRole",
  { "foreign.license_id" => "self.license_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-01 07:44:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fs4bmI/N6Cvicv3RW2qwXQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
