use utf8;
package Koha::Schema::Result::MiscFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MiscFile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<misc_files>

=cut

__PACKAGE__->table("misc_files");

=head1 ACCESSORS

=head2 file_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique id for the file record

=head2 table_tag

  data_type: 'varchar'
  is_nullable: 0
  size: 255

usually table name, or arbitrary unique tag

=head2 record_id

  data_type: 'integer'
  is_nullable: 0

record id from the table this file is associated to

=head2 file_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

file name

=head2 file_type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

MIME type of the file

=head2 file_description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

description given to the file

=head2 file_content

  data_type: 'longblob'
  is_nullable: 0

file content

=head2 date_uploaded

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time the file was added

=cut

__PACKAGE__->add_columns(
  "file_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "table_tag",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "record_id",
  { data_type => "integer", is_nullable => 0 },
  "file_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "file_type",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "file_description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "file_content",
  { data_type => "longblob", is_nullable => 0 },
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

=item * L</file_id>

=back

=cut

__PACKAGE__->set_primary_key("file_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pMegXaTV3y1vCURBL1Zsdg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
