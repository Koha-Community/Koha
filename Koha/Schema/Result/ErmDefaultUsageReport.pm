use utf8;
package Koha::Schema::Result::ErmDefaultUsageReport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmDefaultUsageReport

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_default_usage_reports>

=cut

__PACKAGE__->table("erm_default_usage_reports");

=head1 ACCESSORS

=head2 erm_default_usage_report_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 report_name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

name of the default report

=head2 report_url_params

  data_type: 'longtext'
  is_nullable: 1

url params for the default report

=cut

__PACKAGE__->add_columns(
  "erm_default_usage_report_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "report_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "report_url_params",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</erm_default_usage_report_id>

=back

=cut

__PACKAGE__->set_primary_key("erm_default_usage_report_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-06-15 10:27:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rA1k44Zr273CfmPirG8RMA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub koha_object_class {
    'Koha::ERM::DefaultUsageReport';
}
sub koha_objects_class {
    'Koha::ERM::DefaultUsageReports';
}

1;
