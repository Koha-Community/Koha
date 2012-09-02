package Koha::Schema::Result::MatcherMatchpoint;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::MatcherMatchpoint

=cut

__PACKAGE__->table("matcher_matchpoints");

=head1 ACCESSORS

=head2 matcher_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matchpoint_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "matcher_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matchpoint_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 RELATIONS

=head2 matcher

Type: belongs_to

Related object: L<Koha::Schema::Result::MarcMatcher>

=cut

__PACKAGE__->belongs_to(
  "matcher",
  "Koha::Schema::Result::MarcMatcher",
  { matcher_id => "matcher_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 matchpoint

Type: belongs_to

Related object: L<Koha::Schema::Result::Matchpoint>

=cut

__PACKAGE__->belongs_to(
  "matchpoint",
  "Koha::Schema::Result::Matchpoint",
  { matchpoint_id => "matchpoint_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GBxofoXbX0KRwU1fa5bQ2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
