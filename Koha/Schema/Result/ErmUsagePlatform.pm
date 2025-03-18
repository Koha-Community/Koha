use utf8;
package Koha::Schema::Result::ErmUsagePlatform;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmUsagePlatform

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_usage_platforms>

=cut

__PACKAGE__->table("erm_usage_platforms");

=head1 ACCESSORS

=head2 platform_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 platform

  data_type: 'varchar'
  is_nullable: 1
  size: 255

item title

=head2 usage_data_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

data provider the platform is harvested by

=cut

__PACKAGE__->add_columns(
  "platform_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "platform",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "usage_data_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</platform_id>

=back

=cut

__PACKAGE__->set_primary_key("platform_id");

=head1 RELATIONS

=head2 erm_usage_muses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageMus>

=cut

__PACKAGE__->has_many(
  "erm_usage_muses",
  "Koha::Schema::Result::ErmUsageMus",
  { "foreign.platform_id" => "self.platform_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_yuses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageYus>

=cut

__PACKAGE__->has_many(
  "erm_usage_yuses",
  "Koha::Schema::Result::ErmUsageYus",
  { "foreign.platform_id" => "self.platform_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 usage_data_provider

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmUsageDataProvider>

=cut

__PACKAGE__->belongs_to(
  "usage_data_provider",
  "Koha::Schema::Result::ErmUsageDataProvider",
  { erm_usage_data_provider_id => "usage_data_provider_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-07-24 16:30:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7Qu5XYiD2K+Pn590ZoTs7Q


=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ERM::EUsage::UsagePlatform';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ERM::EUsage::UsagePlatforms';
}

1;
