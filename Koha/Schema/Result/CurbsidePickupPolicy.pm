use utf8;
package Koha::Schema::Result::CurbsidePickupPolicy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CurbsidePickupPolicy

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<curbside_pickup_policy>

=cut

__PACKAGE__->table("curbside_pickup_policy");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 enabled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 enable_waiting_holds_only

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 pickup_interval

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 patrons_per_interval

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 patron_scheduled_pickup

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "enabled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "enable_waiting_holds_only",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "pickup_interval",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "patrons_per_interval",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "patron_scheduled_pickup",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<branchcode>

=over 4

=item * L</branchcode>

=back

=cut

__PACKAGE__->add_unique_constraint("branchcode", ["branchcode"]);

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 curbside_pickup_opening_slots

Type: has_many

Related object: L<Koha::Schema::Result::CurbsidePickupOpeningSlot>

=cut

__PACKAGE__->has_many(
  "curbside_pickup_opening_slots",
  "Koha::Schema::Result::CurbsidePickupOpeningSlot",
  { "foreign.curbside_pickup_policy_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-06-27 11:58:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RyZGROB1+g3kb2bo6mwrUQ

__PACKAGE__->add_columns(
    '+enabled' => { is_boolean => 1 },
    '+enable_waiting_holds_only' => { is_boolean => 1 },
    '+patron_scheduled_pickup' => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::CurbsidePickupPolicy';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::CurbsidePickupPolicies';
}

1;
