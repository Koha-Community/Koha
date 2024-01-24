use utf8;
package Koha::Schema::Result::RecordSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::RecordSource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<record_sources>

=cut

__PACKAGE__->table("record_sources");

=head1 ACCESSORS

=head2 record_source_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Primary key for the `record_sources` table

=head2 name

  data_type: 'text'
  is_nullable: 0

User defined name for the record source

=head2 can_be_edited

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

If records from this source can be edited

=cut

__PACKAGE__->add_columns(
  "record_source_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "can_be_edited",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</record_source_id>

=back

=cut

__PACKAGE__->set_primary_key("record_source_id");

=head1 RELATIONS

=head2 biblio_metadatas

Type: has_many

Related object: L<Koha::Schema::Result::BiblioMetadata>

=cut

__PACKAGE__->has_many(
  "biblio_metadatas",
  "Koha::Schema::Result::BiblioMetadata",
  { "foreign.record_source_id" => "self.record_source_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 deletedbiblio_metadatas

Type: has_many

Related object: L<Koha::Schema::Result::DeletedbiblioMetadata>

=cut

__PACKAGE__->has_many(
  "deletedbiblio_metadatas",
  "Koha::Schema::Result::DeletedbiblioMetadata",
  { "foreign.record_source_id" => "self.record_source_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-24 18:05:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WX72aRYhWBK9bQWr9AJk2A

__PACKAGE__->add_columns(
    '+can_be_edited' => { is_boolean => 1 },
);

1;
