use utf8;
package Koha::Schema::Result::ErmUsageYus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmUsageYus

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_usage_yus>

=cut

__PACKAGE__->table("erm_usage_yus");

=head1 ACCESSORS

=head2 yearly_usage_summary_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 title_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

item title id number

=head2 usage_data_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

item title id number

=head2 year

  data_type: 'integer'
  is_nullable: 1

year of usage statistics

=head2 totalcount

  data_type: 'integer'
  is_nullable: 1

usage count for the title

=head2 metric_type

  data_type: 'varchar'
  is_nullable: 1
  size: 50

metric type for the usage statistic

=head2 report_type

  data_type: 'varchar'
  is_nullable: 1
  size: 50

report type for the usage statistic

=cut

__PACKAGE__->add_columns(
  "yearly_usage_summary_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "usage_data_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "year",
  { data_type => "integer", is_nullable => 1 },
  "totalcount",
  { data_type => "integer", is_nullable => 1 },
  "metric_type",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "report_type",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</yearly_usage_summary_id>

=back

=cut

__PACKAGE__->set_primary_key("yearly_usage_summary_id");

=head1 RELATIONS

=head2 title

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmUsageTitle>

=cut

__PACKAGE__->belongs_to(
  "title",
  "Koha::Schema::Result::ErmUsageTitle",
  { title_id => "title_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-25 13:49:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zXTpOQQ2kTmGzzOSohg0YA


sub koha_object_class {
    'Koha::ERM::YearlyUsage';
}
sub koha_objects_class {
    'Koha::ERM::YearlyUsages';
}

1;
