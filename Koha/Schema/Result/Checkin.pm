use utf8;
package Koha::Schema::Result::Checkin;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Checkin

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<checkins>

=cut

__PACKAGE__->table("checkins");

=head1 ACCESSORS

=head2 checkin_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key from the items table defining which item was checked in

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the borrowers table defining which staff member processed the checkin

=head2 library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

foreign key from the branches table defining where the checkin took place

=head2 desk_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the desks table defining which desk the checkin took place at

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time the checkin was processed

=head2 exempt_fine

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

whether fines were exempted on this checkin

=head2 local_use

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

whether this checkin was recorded as a local use

=head2 checkout_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the old_issues table if this checkin returned a checkout

=head2 transfer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the branchtransfers table if this checkin triggered a transfer

=head2 hold_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the reserves table if this checkin filled a hold

=head2 recall_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the recalls table if this checkin filled a recall

=head2 restriction_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the borrower_debarments table if this checkin triggered a restriction

=head2 claim_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the return_claims table if this checkin resolved a claim

=cut

__PACKAGE__->add_columns(
  "checkin_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "desk_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "exempt_fine",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "local_use",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "checkout_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "transfer_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "hold_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "recall_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "restriction_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "claim_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</checkin_id>

=back

=cut

__PACKAGE__->set_primary_key("checkin_id");

=head1 RELATIONS

=head2 checkout

Type: belongs_to

Related object: L<Koha::Schema::Result::OldIssue>

=cut

__PACKAGE__->belongs_to(
  "checkout",
  "Koha::Schema::Result::OldIssue",
  { issue_id => "checkout_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 claim

Type: belongs_to

Related object: L<Koha::Schema::Result::ReturnClaim>

=cut

__PACKAGE__->belongs_to(
  "claim",
  "Koha::Schema::Result::ReturnClaim",
  { id => "claim_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 desk

Type: belongs_to

Related object: L<Koha::Schema::Result::Desk>

=cut

__PACKAGE__->belongs_to(
  "desk",
  "Koha::Schema::Result::Desk",
  { desk_id => "desk_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 hold

Type: belongs_to

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->belongs_to(
  "hold",
  "Koha::Schema::Result::Reserve",
  { reserve_id => "hold_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 item

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "item_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 recall

Type: belongs_to

Related object: L<Koha::Schema::Result::Recall>

=cut

__PACKAGE__->belongs_to(
  "recall",
  "Koha::Schema::Result::Recall",
  { recall_id => "recall_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 restriction

Type: belongs_to

Related object: L<Koha::Schema::Result::BorrowerDebarment>

=cut

__PACKAGE__->belongs_to(
  "restriction",
  "Koha::Schema::Result::BorrowerDebarment",
  { borrower_debarment_id => "restriction_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 transfer

Type: belongs_to

Related object: L<Koha::Schema::Result::Branchtransfer>

=cut

__PACKAGE__->belongs_to(
  "transfer",
  "Koha::Schema::Result::Branchtransfer",
  { branchtransfer_id => "transfer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 user

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-04-21 12:28:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I4IrfWJHZcDAIKtn4JVY9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->add_columns(
    '+exempt_fine' => { is_boolean => 1 },
    '+local_use'   => { is_boolean => 1 },
);

1;
