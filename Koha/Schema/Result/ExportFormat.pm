use utf8;
package Koha::Schema::Result::ExportFormat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ExportFormat - Used for CSV export

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<export_format>

=cut

__PACKAGE__->table("export_format");

=head1 ACCESSORS

=head2 export_format_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 profile

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'longtext'
  is_nullable: 0

=head2 content

  data_type: 'longtext'
  is_nullable: 0

=head2 csv_separator

  data_type: 'varchar'
  default_value: ','
  is_nullable: 0
  size: 2

=head2 field_separator

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 subfield_separator

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 encoding

  data_type: 'varchar'
  default_value: 'utf8'
  is_nullable: 0
  size: 255

=head2 type

  data_type: 'varchar'
  default_value: 'marc'
  is_nullable: 1
  size: 255

=head2 used_for

  data_type: 'varchar'
  default_value: 'export_records'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "export_format_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "profile",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "longtext", is_nullable => 0 },
  "content",
  { data_type => "longtext", is_nullable => 0 },
  "csv_separator",
  { data_type => "varchar", default_value => ",", is_nullable => 0, size => 2 },
  "field_separator",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "subfield_separator",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "encoding",
  {
    data_type => "varchar",
    default_value => "utf8",
    is_nullable => 0,
    size => 255,
  },
  "type",
  {
    data_type => "varchar",
    default_value => "marc",
    is_nullable => 1,
    size => 255,
  },
  "used_for",
  {
    data_type => "varchar",
    default_value => "export_records",
    is_nullable => 1,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</export_format_id>

=back

=cut

__PACKAGE__->set_primary_key("export_format_id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YSQshI3mJfO0LsOlwvdIdg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
