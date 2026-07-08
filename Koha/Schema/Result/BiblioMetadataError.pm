use utf8;
package Koha::Schema::Result::BiblioMetadataError;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BiblioMetadataError

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblio_metadata_errors>

=cut

__PACKAGE__->table("biblio_metadata_errors");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 metadata_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

FK to biblio_metadata.id

=head2 error_type

  data_type: 'varchar'
  is_nullable: 0
  size: 64

Error type identifier, e.g. nonxml_stripped

=head2 tag

  data_type: 'varchar'
  is_nullable: 1
  size: 3

MARC tag affected, if applicable

=head2 subfield

  data_type: 'varchar'
  is_nullable: 1
  size: 1

MARC subfield code affected, if applicable

=head2 message

  data_type: 'mediumtext'
  is_nullable: 1

Error message details

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "metadata_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "error_type",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "tag",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "subfield",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "message",
  { data_type => "mediumtext", is_nullable => 1 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 metadata

Type: belongs_to

Related object: L<Koha::Schema::Result::BiblioMetadata>

=cut

__PACKAGE__->belongs_to(
  "metadata",
  "Koha::Schema::Result::BiblioMetadata",
  { id => "metadata_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-07-08 10:57:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QpQBMYpjcA78mS/8zfGOcg


1;
