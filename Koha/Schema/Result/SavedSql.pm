use utf8;
package Koha::Schema::Result::SavedSql;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SavedSql

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<saved_sql>

=cut

__PACKAGE__->table("saved_sql");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

=head2 date_created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 last_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 savedsql

  data_type: 'mediumtext'
  is_nullable: 1

=head2 last_run

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 report_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 cache_expiry

  data_type: 'integer'
  default_value: 300
  is_nullable: 0

=head2 public

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 report_area

  data_type: 'varchar'
  is_nullable: 1
  size: 6

=head2 report_group

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 report_subgroup

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_nullable => 1 },
  "date_created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "last_modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "savedsql",
  { data_type => "mediumtext", is_nullable => 1 },
  "last_run",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "report_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "cache_expiry",
  { data_type => "integer", default_value => 300, is_nullable => 0 },
  "public",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "report_area",
  { data_type => "varchar", is_nullable => 1, size => 6 },
  "report_group",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "report_subgroup",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7UCqSsNMGdq+S7MwZulmwA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
