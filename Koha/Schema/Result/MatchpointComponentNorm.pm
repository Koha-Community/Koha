use utf8;
package Koha::Schema::Result::MatchpointComponentNorm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MatchpointComponentNorm

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<matchpoint_component_norms>

=cut

__PACKAGE__->table("matchpoint_component_norms");

=head1 ACCESSORS

=head2 matchpoint_component_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sequence

  accessor: undef
  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 norm_routine

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=cut

__PACKAGE__->add_columns(
  "matchpoint_component_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sequence",
  {
    accessor      => undef,
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 0,
  },
  "norm_routine",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
);

=head1 RELATIONS

=head2 matchpoint_component

Type: belongs_to

Related object: L<Koha::Schema::Result::MatchpointComponent>

=cut

__PACKAGE__->belongs_to(
  "matchpoint_component",
  "Koha::Schema::Result::MatchpointComponent",
  { matchpoint_component_id => "matchpoint_component_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Aj5cUNNx7G5iq0w0AFVgtA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
