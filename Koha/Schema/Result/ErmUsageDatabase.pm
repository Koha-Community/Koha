use utf8;
package Koha::Schema::Result::ErmUsageDatabase;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmUsageDatabase

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_usage_databases>

=cut

__PACKAGE__->table("erm_usage_databases");

=head1 ACCESSORS

=head2 database_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 database

  data_type: 'varchar'
  is_nullable: 1
  size: 255

item title

=head2 platform

  data_type: 'varchar'
  is_nullable: 1
  size: 24

database platform

=head2 publisher

  data_type: 'varchar'
  is_nullable: 1
  size: 24

Publisher for the database

=head2 publisher_id

  data_type: 'varchar'
  is_nullable: 1
  size: 24

Publisher ID for the database

=head2 usage_data_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

data provider the database is harvested by

=cut

__PACKAGE__->add_columns(
  "database_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "database",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "platform",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "publisher",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "publisher_id",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "usage_data_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</database_id>

=back

=cut

__PACKAGE__->set_primary_key("database_id");

=head1 RELATIONS

=head2 erm_usage_muses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageMus>

=cut

__PACKAGE__->has_many(
  "erm_usage_muses",
  "Koha::Schema::Result::ErmUsageMus",
  { "foreign.database_id" => "self.database_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_yuses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageYus>

=cut

__PACKAGE__->has_many(
  "erm_usage_yuses",
  "Koha::Schema::Result::ErmUsageYus",
  { "foreign.database_id" => "self.database_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-07-26 11:45:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N/qxjz0Jz0NOI6lFVkUXhg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub koha_object_class {
    'Koha::ERM::UsageDatabase';
}

sub koha_objects_class {
    'Koha::ERM::UsageDatabases';
}
1;
