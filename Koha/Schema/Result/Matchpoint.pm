use utf8;
package Koha::Schema::Result::Matchpoint;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Matchpoint

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<matchpoints>

=cut

__PACKAGE__->table("matchpoints");

=head1 ACCESSORS

=head2 matcher_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matchpoint_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 search_index

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 30

=head2 score

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "matcher_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matchpoint_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "search_index",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 30 },
  "score",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</matchpoint_id>

=back

=cut

__PACKAGE__->set_primary_key("matchpoint_id");

=head1 RELATIONS

=head2 matchchecks_source_matchpoints

Type: has_many

Related object: L<Koha::Schema::Result::Matchcheck>

=cut

__PACKAGE__->has_many(
  "matchchecks_source_matchpoints",
  "Koha::Schema::Result::Matchcheck",
  { "foreign.source_matchpoint_id" => "self.matchpoint_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matchchecks_target_matchpoints

Type: has_many

Related object: L<Koha::Schema::Result::Matchcheck>

=cut

__PACKAGE__->has_many(
  "matchchecks_target_matchpoints",
  "Koha::Schema::Result::Matchcheck",
  { "foreign.target_matchpoint_id" => "self.matchpoint_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matcher

Type: belongs_to

Related object: L<Koha::Schema::Result::MarcMatcher>

=cut

__PACKAGE__->belongs_to(
  "matcher",
  "Koha::Schema::Result::MarcMatcher",
  { matcher_id => "matcher_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 matcher_matchpoints

Type: has_many

Related object: L<Koha::Schema::Result::MatcherMatchpoint>

=cut

__PACKAGE__->has_many(
  "matcher_matchpoints",
  "Koha::Schema::Result::MatcherMatchpoint",
  { "foreign.matchpoint_id" => "self.matchpoint_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matchpoint_components

Type: has_many

Related object: L<Koha::Schema::Result::MatchpointComponent>

=cut

__PACKAGE__->has_many(
  "matchpoint_components",
  "Koha::Schema::Result::MatchpointComponent",
  { "foreign.matchpoint_id" => "self.matchpoint_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KvZ0QM+OoJ+xaUKdkPGASg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
