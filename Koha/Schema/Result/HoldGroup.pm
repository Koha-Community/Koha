use utf8;
package Koha::Schema::Result::HoldGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::HoldGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<hold_groups>

=cut

__PACKAGE__->table("hold_groups");

=head1 ACCESSORS

=head2 hold_group_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key, linking this to the borrowers table

=head2 visual_hold_group_id

  data_type: 'integer'
  is_nullable: 1

visual ID for this hold group, in the context of the related patron

=cut

__PACKAGE__->add_columns(
  "hold_group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "visual_hold_group_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</hold_group_id>

=back

=cut

__PACKAGE__->set_primary_key("hold_group_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 hold_groups_target_hold

Type: might_have

Related object: L<Koha::Schema::Result::HoldGroupsTargetHold>

=cut

__PACKAGE__->might_have(
  "hold_groups_target_hold",
  "Koha::Schema::Result::HoldGroupsTargetHold",
  { "foreign.hold_group_id" => "self.hold_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.hold_group_id" => "self.hold_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.hold_group_id" => "self.hold_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-11-03 19:54:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o9/2a3gatQnmc7nTYRpUPQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
