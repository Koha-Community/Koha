use utf8;
package Koha::Schema::Result::RecordSourcesLibraryGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::RecordSourcesLibraryGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<record_sources_library_groups>

=cut

__PACKAGE__->table("record_sources_library_groups");

=head1 ACCESSORS

=head2 record_source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the record source

=head2 library_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the library group exempt from the record source lock

=cut

__PACKAGE__->add_columns(
  "record_source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "library_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</record_source_id>

=item * L</library_group_id>

=back

=cut

__PACKAGE__->set_primary_key("record_source_id", "library_group_id");

=head1 RELATIONS

=head2 library_group

Type: belongs_to

Related object: L<Koha::Schema::Result::LibraryGroup>

=cut

__PACKAGE__->belongs_to(
  "library_group",
  "Koha::Schema::Result::LibraryGroup",
  { id => "library_group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 record_source

Type: belongs_to

Related object: L<Koha::Schema::Result::RecordSource>

=cut

__PACKAGE__->belongs_to(
  "record_source",
  "Koha::Schema::Result::RecordSource",
  { record_source_id => "record_source_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-08-11 17:09:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V4UpowbalbuXjTZ53ttX7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
