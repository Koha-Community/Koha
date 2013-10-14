use utf8;
package Koha::Schema::Result::OaiSetsDescription;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OaiSetsDescription

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<oai_sets_descriptions>

=cut

__PACKAGE__->table("oai_sets_descriptions");

=head1 ACCESSORS

=head2 set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 RELATIONS

=head2 set

Type: belongs_to

Related object: L<Koha::Schema::Result::OaiSet>

=cut

__PACKAGE__->belongs_to(
  "set",
  "Koha::Schema::Result::OaiSet",
  { id => "set_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:W8gqXVcVgEpJUdsKQsPn5A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
