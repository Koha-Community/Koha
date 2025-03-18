use utf8;
package Koha::Schema::Result::CheckoutRenewal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CheckoutRenewal

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<checkout_renewals>

=cut

__PACKAGE__->table("checkout_renewals");

=head1 ACCESSORS

=head2 renewal_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 checkout_id

  data_type: 'integer'
  is_nullable: 1

the id of the checkout this renewal pertains to

=head2 renewer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

the id of the user who processed the renewal

=head2 seen

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

boolean denoting whether the item was present or not

=head2 interface

  data_type: 'varchar'
  is_nullable: 0
  size: 16

the interface this renewal took place on

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

the date and time the renewal took place

=head2 renewal_type

  data_type: 'enum'
  default_value: 'Manual'
  extra: {list => ["Automatic","Manual"]}
  is_nullable: 0

whether the renewal was an automatic or manual renewal

=cut

__PACKAGE__->add_columns(
  "renewal_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "checkout_id",
  { data_type => "integer", is_nullable => 1 },
  "renewer_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "seen",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "interface",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "renewal_type",
  {
    data_type => "enum",
    default_value => "Manual",
    extra => { list => ["Automatic", "Manual"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</renewal_id>

=back

=cut

__PACKAGE__->set_primary_key("renewal_id");

=head1 RELATIONS

=head2 renewer

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "renewer",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "renewer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-12-08 10:49:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Si1gkXWqpvt98YN0dO7vgw

=head2 checkout

Type: belongs_to

Related object: L<Koha::Schema::Result::Issue>

=cut

__PACKAGE__->belongs_to(
    "checkout",
    "Koha::Schema::Result::Issue",
    { "foreign.issue_id" => "self.checkout_id" },
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
    { "foreign.issue_id" => "self.checkout_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
    },
);

__PACKAGE__->add_columns(
    '+seen' => { is_boolean => 1 }
);

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Checkouts::Renewals';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Checkouts::Renewal';
}

1;
