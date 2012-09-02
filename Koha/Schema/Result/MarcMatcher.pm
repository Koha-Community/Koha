package Koha::Schema::Result::MarcMatcher;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::MarcMatcher

=cut

__PACKAGE__->table("marc_matchers");

=head1 ACCESSORS

=head2 matcher_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 record_type

  data_type: 'varchar'
  default_value: 'biblio'
  is_nullable: 0
  size: 10

=head2 threshold

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "matcher_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "record_type",
  {
    data_type => "varchar",
    default_value => "biblio",
    is_nullable => 0,
    size => 10,
  },
  "threshold",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("matcher_id");

=head1 RELATIONS

=head2 matchchecks

Type: has_many

Related object: L<Koha::Schema::Result::Matchcheck>

=cut

__PACKAGE__->has_many(
  "matchchecks",
  "Koha::Schema::Result::Matchcheck",
  { "foreign.matcher_id" => "self.matcher_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matcher_matchpoints

Type: has_many

Related object: L<Koha::Schema::Result::MatcherMatchpoint>

=cut

__PACKAGE__->has_many(
  "matcher_matchpoints",
  "Koha::Schema::Result::MatcherMatchpoint",
  { "foreign.matcher_id" => "self.matcher_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 matchpoints

Type: has_many

Related object: L<Koha::Schema::Result::Matchpoint>

=cut

__PACKAGE__->has_many(
  "matchpoints",
  "Koha::Schema::Result::Matchpoint",
  { "foreign.matcher_id" => "self.matcher_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iZyWhA28vO7VHWXtE473TQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
