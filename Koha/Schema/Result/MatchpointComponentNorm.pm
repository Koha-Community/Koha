package Koha::Schema::Result::MatchpointComponentNorm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::MatchpointComponentNorm

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
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bfVMJiFqfjhc8fSKXNEtBA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
