use utf8;
package Koha::Schema::Result::HoldGroupsTargetHold;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::HoldGroupsTargetHold

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<hold_groups_target_holds>

=cut

__PACKAGE__->table("hold_groups_target_holds");

=head1 ACCESSORS

=head2 hold_group_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

foreign key, linking this to the hold_groups table

=head2 reserve_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key, linking this to the reserves table

=cut

__PACKAGE__->add_columns(
  "hold_group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "reserve_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</hold_group_id>

=item * L</reserve_id>

=back

=cut

__PACKAGE__->set_primary_key("hold_group_id", "reserve_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<uq_hold_group_target_holds_hold_group_id>

=over 4

=item * L</hold_group_id>

=back

=cut

__PACKAGE__->add_unique_constraint("uq_hold_group_target_holds_hold_group_id", ["hold_group_id"]);

=head2 C<uq_hold_group_target_holds_reserve_id>

=over 4

=item * L</reserve_id>

=back

=cut

__PACKAGE__->add_unique_constraint("uq_hold_group_target_holds_reserve_id", ["reserve_id"]);

=head1 RELATIONS

=head2 hold_group

Type: belongs_to

Related object: L<Koha::Schema::Result::HoldGroup>

=cut

__PACKAGE__->belongs_to(
  "hold_group",
  "Koha::Schema::Result::HoldGroup",
  { hold_group_id => "hold_group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 reserve

Type: belongs_to

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->belongs_to(
  "reserve",
  "Koha::Schema::Result::Reserve",
  { reserve_id => "reserve_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-11-03 19:54:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lrc3J+aResiHmuUk0TowLQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
