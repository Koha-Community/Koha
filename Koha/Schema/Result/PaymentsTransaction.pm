use utf8;
package Koha::Schema::Result::PaymentsTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PaymentsTransaction

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<payments_transactions>

=cut

__PACKAGE__->table("payments_transactions");

=head1 ACCESSORS

=head2 transaction_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 accountlines_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 user_branch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 manager_id

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'enum'
  default_value: 'pending'
  extra: {list => ["paid","pending","cancelled","unsent"]}
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 price_in_cents

  data_type: 'integer'
  is_nullable: 0

=head2 is_self_payment

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "transaction_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "accountlines_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "user_branch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "manager_id",
  { data_type => "integer", is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "pending",
    extra => { list => ["paid", "pending", "cancelled", "unsent"] },
    is_nullable => 1,
  },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
  "description",
  { data_type => "text", is_nullable => 0 },
  "price_in_cents",
  { data_type => "integer", is_nullable => 0 },
  "is_self_payment",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</transaction_id>

=back

=cut

__PACKAGE__->set_primary_key("transaction_id");

=head1 RELATIONS

=head2 accountline

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "accountline",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "accountlines_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 payments_transactions_accountlines

Type: has_many

Related object: L<Koha::Schema::Result::PaymentsTransactionsAccountline>

=cut

__PACKAGE__->has_many(
  "payments_transactions_accountlines",
  "Koha::Schema::Result::PaymentsTransactionsAccountline",
  { "foreign.transaction_id" => "self.transaction_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uSp3bomKL81myCdBWRaznA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
