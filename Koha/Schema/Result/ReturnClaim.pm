use utf8;
package Koha::Schema::Result::ReturnClaim;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ReturnClaim

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<return_claims>

=cut

__PACKAGE__->table("return_claims");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Unique ID of the return claim

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

ID of the item

=head2 issue_id

  data_type: 'integer'
  is_nullable: 1

ID of the checkout that triggered the claim

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

ID of the patron

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

Notes about the claim

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Time and date the claim was created

=head2 created_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

ID of the staff member that registered the claim

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Time and date of the latest change on the claim (notes)

=head2 updated_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

ID of the staff member that updated the claim

=head2 resolution

  data_type: 'varchar'
  is_nullable: 1
  size: 80

Resolution code (RETURN_CLAIM_RESOLUTION AVs)

=head2 resolved_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Time and date the claim was resolved

=head2 resolved_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

ID of the staff member that resolved the claim

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "issue_id",
  { data_type => "integer", is_nullable => 1 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "created_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "updated_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "updated_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "resolution",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "resolved_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "resolved_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<item_issue>

=over 4

=item * L</itemnumber>

=item * L</issue_id>

=back

=cut

__PACKAGE__->add_unique_constraint("item_issue", ["itemnumber", "issue_id"]);

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 created_by

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "created_by",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "created_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 resolved_by

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "resolved_by",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "resolved_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 updated_by

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "updated_by",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "updated_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-18 15:06:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Xj7Juwt0e0wxEf+CZRfyMQ

=head2 checkout

Type: belongs_to

Related object: L<Koha::Schema::Result::Issue>

=cut

__PACKAGE__->belongs_to(
    "checkout",
    "Koha::Schema::Result::Issue",
    { issue_id => "issue_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
    },
);

=head2 old_checkout

Type: belongs_to

Related object: L<Koha::Schema::Result::OldIssue>

=cut

__PACKAGE__->belongs_to(
    "old_checkout",
    "Koha::Schema::Result::OldIssue",
    { issue_id => "issue_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
    },
);

=head2 item

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Checkouts::ReturnClaims';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Checkouts::ReturnClaim';
}

1;
