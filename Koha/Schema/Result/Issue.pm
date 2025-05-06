use utf8;
package Koha::Schema::Result::Issue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Issue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<issues>

=cut

__PACKAGE__->table("issues");

=head1 ACCESSORS

=head2 issue_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key for issues table

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key, linking this to the borrowers table for the patron this item was checked out to

=head2 issuer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key, linking this to the borrowers table for the user who checked out this item

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key, linking this to the items table for the item that was checked out

=head2 date_due

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

datetime the item is due (yyyy-mm-dd hh:mm::ss)

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

foreign key, linking to the branches table for the location the item was checked out

=head2 returndate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the item was returned, will be NULL until moved to old_issues

=head2 checkin_library

  data_type: 'varchar'
  is_nullable: 1
  size: 10

library the item was checked in at

=head2 lastreneweddate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the item was last renewed

=head2 renewals_count

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

lists the number of times the item was renewed

=head2 unseen_renewals

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

lists the number of consecutive times the item was renewed without being seen

=head2 auto_renew

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

automatic renewal

=head2 auto_renew_error

  data_type: 'varchar'
  is_nullable: 1
  size: 32

automatic renewal error

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

the date and time this record was last touched

=head2 issuedate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the item was checked out or issued

=head2 onsite_checkout

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

in house use flag

=head2 note

  data_type: 'longtext'
  is_nullable: 1

issue note text

=head2 notedate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

datetime of issue note (yyyy-mm-dd hh:mm::ss)

=head2 noteseen

  data_type: 'tinyint'
  is_nullable: 1

describes whether checkout note has been seen 1, not been seen 0 or doesn't exist null

=cut

__PACKAGE__->add_columns(
  "issue_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "issuer_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date_due",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "returndate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "checkin_library",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "lastreneweddate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "renewals_count",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "unseen_renewals",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "auto_renew",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "auto_renew_error",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "issuedate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "onsite_checkout",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "note",
  { data_type => "longtext", is_nullable => 1 },
  "notedate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "noteseen",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</issue_id>

=back

=cut

__PACKAGE__->set_primary_key("issue_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<itemnumber>

=over 4

=item * L</itemnumber>

=back

=cut

__PACKAGE__->add_unique_constraint("itemnumber", ["itemnumber"]);

=head1 RELATIONS

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.issue_id" => "self.issue_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 issuer

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "issuer",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "issuer_id" },
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
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-05-06 16:22:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sCGlwnT9B7Mn1k80Gme6hw

__PACKAGE__->add_columns(
    '+auto_renew'      => { is_boolean => 1 },
    '+noteseen'        => { is_boolean => 1 },
    '+onsite_checkout' => { is_boolean => 1 }
);

__PACKAGE__->belongs_to(
    "patron",
    "Koha::Schema::Result::Borrower",
    { borrowernumber => "borrowernumber" },
    { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "branch",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { "foreign.branchcode" => "self.branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 renewals

Type: has_many

Related object: L<Koha::Schema::Result::CheckoutRenewal>

=cut

__PACKAGE__->has_many(
    "renewals",
    "Koha::Schema::Result::CheckoutRenewal",
    { "foreign.checkout_id" => "self.issue_id" },
    { cascade_copy       => 0, cascade_delete => 0 },
);

=head2 return_claim

Type: might_have

Related object: L<Koha::Schema::Result::ReturnClaim>

=cut

__PACKAGE__->might_have(
    "return_claim",
    "Koha::Schema::Result::ReturnClaim",
    { "foreign.issue_id" => "self.issue_id" },
    { cascade_copy       => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
    "account_lines",
    "Koha::Schema::Result::Accountline",
    { "foreign.issue_id" => "self.issue_id" },
    { cascade_copy       => 0, cascade_delete => 0 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Checkout';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Checkouts';
}

1;
