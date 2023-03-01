use utf8;
package Koha::Schema::Result::ErmUsageDataProvider;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmUsageDataProvider

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_usage_data_providers>

=cut

__PACKAGE__->table("erm_usage_data_providers");

=head1 ACCESSORS

=head2 erm_usage_data_provider_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

name of the data provider

=head2 description

  data_type: 'longtext'
  is_nullable: 1

description of the data provider

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

current status of the harvester - active/inactive

=head2 method

  data_type: 'varchar'
  is_nullable: 1
  size: 80

method of the harvester

=head2 aggregator

  data_type: 'varchar'
  is_nullable: 1
  size: 80

aggregator of the harvester

=head2 service_type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

service_type of the harvester

=head2 service_url

  data_type: 'varchar'
  is_nullable: 1
  size: 80

service_url of the harvester

=head2 report_release

  data_type: 'varchar'
  is_nullable: 1
  size: 80

report_release of the harvester

=head2 begin_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

start date of the harvester

=head2 end_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

end date of the harvester

=head2 customer_id

  data_type: 'varchar'
  is_nullable: 1
  size: 50

sushi customer id

=head2 requestor_id

  data_type: 'varchar'
  is_nullable: 1
  size: 50

sushi requestor id

=head2 api_key

  data_type: 'varchar'
  is_nullable: 1
  size: 80

sushi api key

=head2 requestor_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

requestor name

=head2 requestor_email

  data_type: 'varchar'
  is_nullable: 1
  size: 80

requestor email

=head2 report_types

  data_type: 'varchar'
  is_nullable: 1
  size: 255

report types provided by the harvester

=cut

__PACKAGE__->add_columns(
  "erm_usage_data_provider_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "method",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "aggregator",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "service_type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "service_url",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "report_release",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "begin_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "end_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "customer_id",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "requestor_id",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "api_key",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "requestor_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "requestor_email",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "report_types",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</erm_usage_data_provider_id>

=back

=cut

__PACKAGE__->set_primary_key("erm_usage_data_provider_id");

=head1 RELATIONS

=head2 erm_counter_files

Type: has_many

Related object: L<Koha::Schema::Result::ErmCounterFile>

=cut

__PACKAGE__->has_many(
  "erm_counter_files",
  "Koha::Schema::Result::ErmCounterFile",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_databases

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageDatabase>

=cut

__PACKAGE__->has_many(
  "erm_usage_databases",
  "Koha::Schema::Result::ErmUsageDatabase",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_items

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageItem>

=cut

__PACKAGE__->has_many(
  "erm_usage_items",
  "Koha::Schema::Result::ErmUsageItem",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_muses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageMus>

=cut

__PACKAGE__->has_many(
  "erm_usage_muses",
  "Koha::Schema::Result::ErmUsageMus",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_platforms

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsagePlatform>

=cut

__PACKAGE__->has_many(
  "erm_usage_platforms",
  "Koha::Schema::Result::ErmUsagePlatform",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_titles

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageTitle>

=cut

__PACKAGE__->has_many(
  "erm_usage_titles",
  "Koha::Schema::Result::ErmUsageTitle",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_yuses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageYus>

=cut

__PACKAGE__->has_many(
  "erm_usage_yuses",
  "Koha::Schema::Result::ErmUsageYus",
  {
    "foreign.usage_data_provider_id" => "self.erm_usage_data_provider_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-07-26 14:35:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AVt5SSRe/g6EmvBtASWHPA

# __PACKAGE__->add_columns(
#     '+active' => { is_boolean => 1 }
# );

sub koha_object_class {
    'Koha::ERM::UsageDataProvider';
}
sub koha_objects_class {
    'Koha::ERM::UsageDataProviders';
}

1;
