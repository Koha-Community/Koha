use utf8;
package Koha::Schema::Result::ReportsDictionary;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ReportsDictionary

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<reports_dictionary>

=cut

__PACKAGE__->table("reports_dictionary");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

name for this definition

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

description for this definition

=head2 date_created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date and time this definition was created

=head2 date_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date and time this definition was last modified

=head2 saved_sql

  data_type: 'mediumtext'
  is_nullable: 1

SQL snippet for us in reports

=head2 report_area

  data_type: 'varchar'
  is_nullable: 1
  size: 6

Koha module this definition is for Circulation, Catalog, Patrons, Acquistions, Accounts)

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "date_created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "date_modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "saved_sql",
  { data_type => "mediumtext", is_nullable => 1 },
  "report_area",
  { data_type => "varchar", is_nullable => 1, size => 6 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7r8vJ2yWD3yQCyri+uNSRw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
