use utf8;
package Koha::Schema::Result::MatchpointComponent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MatchpointComponent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<matchpoint_components>

=cut

__PACKAGE__->table("matchpoint_components");

=head1 ACCESSORS

=head2 matchpoint_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matchpoint_component_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sequence

  accessor: undef
  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 tag

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 3

=head2 subfields

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 offset

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 length

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "matchpoint_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matchpoint_component_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sequence",
  {
    accessor      => undef,
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 0,
  },
  "tag",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
  "subfields",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "offset",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "length",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</matchpoint_component_id>

=back

=cut

__PACKAGE__->set_primary_key("matchpoint_component_id");

=head1 RELATIONS

=head2 matchpoint

Type: belongs_to

Related object: L<Koha::Schema::Result::Matchpoint>

=cut

__PACKAGE__->belongs_to(
  "matchpoint",
  "Koha::Schema::Result::Matchpoint",
  { matchpoint_id => "matchpoint_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 matchpoint_component_norms

Type: has_many

Related object: L<Koha::Schema::Result::MatchpointComponentNorm>

=cut

__PACKAGE__->has_many(
  "matchpoint_component_norms",
  "Koha::Schema::Result::MatchpointComponentNorm",
  {
    "foreign.matchpoint_component_id" => "self.matchpoint_component_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R9niKe/wGJXD+ZVkIP5Wpg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
