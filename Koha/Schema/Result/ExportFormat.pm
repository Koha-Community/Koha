package Koha::Schema::Result::ExportFormat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ExportFormat

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

  data_type: 'mediumtext'
  is_nullable: 0

=head2 marcfields

  data_type: 'mediumtext'
  is_nullable: 0

=head2 csv_separator

  data_type: 'varchar'
  is_nullable: 0
  size: 2

=head2 field_separator

  data_type: 'varchar'
  is_nullable: 0
  size: 2

=head2 subfield_separator

  data_type: 'varchar'
  is_nullable: 0
  size: 2

=head2 encoding

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "export_format_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "profile",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "marcfields",
  { data_type => "mediumtext", is_nullable => 0 },
  "csv_separator",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "field_separator",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "subfield_separator",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "encoding",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("export_format_id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bUCNW2Ek6JxBjlVcO1TQ1g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
