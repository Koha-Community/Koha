use utf8;
package Koha::Schema::Result::ErmCounterFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmCounterFile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_counter_files>

=cut

__PACKAGE__->table("erm_counter_files");

=head1 ACCESSORS

=head2 erm_counter_files_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 usage_data_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key to erm_usage_data_providers

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

type of counter file

=head2 filename

  data_type: 'varchar'
  is_nullable: 1
  size: 80

name of the counter file

=head2 file_content

  data_type: 'longblob'
  is_nullable: 1

content of the counter file

=head2 date_uploaded

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

counter file upload date

=cut

__PACKAGE__->add_columns(
  "erm_counter_files_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "usage_data_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "file_content",
  { data_type => "longblob", is_nullable => 1 },
  "date_uploaded",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</erm_counter_files_id>

=back

=cut

__PACKAGE__->set_primary_key("erm_counter_files_id");

=head1 RELATIONS

=head2 erm_counter_logs

Type: has_many

Related object: L<Koha::Schema::Result::ErmCounterLog>

=cut

__PACKAGE__->has_many(
  "erm_counter_logs",
  "Koha::Schema::Result::ErmCounterLog",
  { "foreign.counter_files_id" => "self.erm_counter_files_id" },
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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-05-05 10:42:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zGKQM9bikamF7J64+neesw


=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ERM::EUsage::CounterFile';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ERM::EUsage::CounterFiles';
}

1;
