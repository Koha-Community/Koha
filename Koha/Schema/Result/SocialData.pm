use utf8;
package Koha::Schema::Result::SocialData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SocialData

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<social_data>

=cut

__PACKAGE__->table("social_data");

=head1 ACCESSORS

=head2 isbn

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 30

=head2 num_critics

  data_type: 'integer'
  is_nullable: 1

=head2 num_critics_pro

  data_type: 'integer'
  is_nullable: 1

=head2 num_quotations

  data_type: 'integer'
  is_nullable: 1

=head2 num_videos

  data_type: 'integer'
  is_nullable: 1

=head2 score_avg

  data_type: 'decimal'
  is_nullable: 1
  size: [5,2]

=head2 num_scores

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "isbn",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 30 },
  "num_critics",
  { data_type => "integer", is_nullable => 1 },
  "num_critics_pro",
  { data_type => "integer", is_nullable => 1 },
  "num_quotations",
  { data_type => "integer", is_nullable => 1 },
  "num_videos",
  { data_type => "integer", is_nullable => 1 },
  "score_avg",
  { data_type => "decimal", is_nullable => 1, size => [5, 2] },
  "num_scores",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</isbn>

=back

=cut

__PACKAGE__->set_primary_key("isbn");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Medc/ZzPVp5Eq+adFoqQoA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
