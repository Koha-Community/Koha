use utf8;
package Koha::Schema::Result::BorrowerFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerFile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_files>

=cut

__PACKAGE__->table("borrower_files");

=head1 ACCESSORS

=head2 file_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 file_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 file_type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 file_description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 file_content

  data_type: 'longblob'
  is_nullable: 0

=head2 date_uploaded

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "file_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sbkf7bvdO4CgmiBLgIwYQg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
