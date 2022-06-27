use utf8;
package Koha::Schema::Result::CurbsidePickupIssue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CurbsidePickupIssue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<curbside_pickup_issues>

=cut

__PACKAGE__->table("curbside_pickup_issues");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 curbside_pickup_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 issue_id

  data_type: 'integer'
  is_nullable: 0

=head2 reserve_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "curbside_pickup_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "issue_id",
  { data_type => "integer", is_nullable => 0 },
  "reserve_id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 curbside_pickup

Type: belongs_to

Related object: L<Koha::Schema::Result::CurbsidePickup>

=cut

__PACKAGE__->belongs_to(
  "curbside_pickup",
  "Koha::Schema::Result::CurbsidePickup",
  { id => "curbside_pickup_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-06-27 11:58:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U8r/RLbAi1yGXexYWUYjtQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
