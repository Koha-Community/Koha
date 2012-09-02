package Koha::Schema::Result::Matchcheck;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Matchcheck

=cut

__PACKAGE__->table("matchchecks");

=head1 ACCESSORS

=head2 matcher_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matchcheck_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 source_matchpoint_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 target_matchpoint_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "matcher_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matchcheck_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "source_matchpoint_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "target_matchpoint_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("matchcheck_id");

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

=head2 source_matchpoint

Type: belongs_to

Related object: L<Koha::Schema::Result::Matchpoint>

=cut

__PACKAGE__->belongs_to(
  "source_matchpoint",
  "Koha::Schema::Result::Matchpoint",
  { matchpoint_id => "source_matchpoint_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 target_matchpoint

Type: belongs_to

Related object: L<Koha::Schema::Result::Matchpoint>

=cut

__PACKAGE__->belongs_to(
  "target_matchpoint",
  "Koha::Schema::Result::Matchpoint",
  { matchpoint_id => "target_matchpoint_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R2duGZidKaVVqnfQP5pSvQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
