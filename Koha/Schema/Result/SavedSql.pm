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

unique id and primary key assigned by Koha

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

the staff member who created this report (borrowers.borrowernumber)

=head2 date_created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date this report was created

=head2 last_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date this report was last edited

=head2 savedsql

  data_type: 'mediumtext'
  is_nullable: 1

the SQL for this report

=head2 last_run

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 report_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

the name of this report

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

always 1 for tabular

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

the notes or description given to this report

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

=head2 mana_id

  data_type: 'integer'
  is_nullable: 1

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
  "mana_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:198dNG9DGQzop+s5IHy7sw

__PACKAGE__->add_columns(
    '+public' => { is_boolean => 1 }
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Report';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Reports';
}

1;
