use utf8;
package Koha::Schema::Result::BiblioMetadata;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BiblioMetadata

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblio_metadata>

=cut

__PACKAGE__->table("biblio_metadata");

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
  is_foreign_key: 1
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
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<biblio_metadata_uniq_key>

=over 4

=item * L</biblioitemnumber>

=item * L</biblionumber>

=item * L</format>

=item * L</marcflavour>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "biblio_metadata_uniq_key",
  ["biblioitemnumber", "biblionumber", "format", "marcflavour"],
);

=head1 RELATIONS

=head2 biblioitemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblioitem>

=cut

__PACKAGE__->belongs_to(
  "biblioitemnumber",
  "Koha::Schema::Result::Biblioitem",
  { biblioitemnumber => "biblioitemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2017-03-14 18:44:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Hge4/lIJmyxCqxZ+D50Cjw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
