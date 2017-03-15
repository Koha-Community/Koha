use utf8;
package Koha::Schema::Result::DeletedbiblioMetadata;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::DeletedbiblioMetadata

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<deletedbiblio_metadata>

=cut

__PACKAGE__->table("deletedbiblio_metadata");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  is_nullable: 0

=head2 format

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 marcflavour

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 metadata

  data_type: 'longtext'
  is_nullable: 0

=head2 biblioitemnumber

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_nullable => 0 },
  "format",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "marcflavour",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "metadata",
  { data_type => "longtext", is_nullable => 0 },
  "biblioitemnumber",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<deletedbiblio_metadata_uniq_key>

=over 4

=item * L</biblioitemnumber>

=item * L</biblionumber>

=item * L</format>

=item * L</marcflavour>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "deletedbiblio_metadata_uniq_key",
  ["biblioitemnumber", "biblionumber", "format", "marcflavour"],
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2017-03-15 12:08:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:s2+vDtfa+QqaWtXgPT6fZg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
