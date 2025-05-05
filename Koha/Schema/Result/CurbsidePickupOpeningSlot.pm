use utf8;
package Koha::Schema::Result::CurbsidePickupOpeningSlot;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CurbsidePickupOpeningSlot

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<curbside_pickup_opening_slots>

=cut

__PACKAGE__->table("curbside_pickup_opening_slots");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 curbside_pickup_policy_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 day

  data_type: 'tinyint'
  is_nullable: 0

=head2 start_hour

  data_type: 'integer'
  is_nullable: 0

=head2 start_minute

  data_type: 'integer'
  is_nullable: 0

=head2 end_hour

  data_type: 'integer'
  is_nullable: 0

=head2 end_minute

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "curbside_pickup_policy_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "day",
  { data_type => "tinyint", is_nullable => 0 },
  "start_hour",
  { data_type => "integer", is_nullable => 0 },
  "start_minute",
  { data_type => "integer", is_nullable => 0 },
  "end_hour",
  { data_type => "integer", is_nullable => 0 },
  "end_minute",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 curbside_pickup_policy

Type: belongs_to

Related object: L<Koha::Schema::Result::CurbsidePickupPolicy>

=cut

__PACKAGE__->belongs_to(
  "curbside_pickup_policy",
  "Koha::Schema::Result::CurbsidePickupPolicy",
  { id => "curbside_pickup_policy_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-06-27 11:58:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5kzC0AAB9LL0gR+FFnmYgw

__PACKAGE__->add_columns(
    '+day' => { is_boolean => 1 },
);

1;
