use utf8;
package Koha::Schema::Result::PaymentsTransactionsAccountline;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PaymentsTransactionsAccountline

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<payments_transactions_accountlines>

=cut

__PACKAGE__->table("payments_transactions_accountlines");

=head1 ACCESSORS

=head2 transactions_accountlines_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 transaction_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 accountlines_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 paid_price_cents

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "transactions_accountlines_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "transaction_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "accountlines_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "paid_price_cents",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</transactions_accountlines_id>

=back

=cut

__PACKAGE__->set_primary_key("transactions_accountlines_id");

=head1 RELATIONS

=head2 accountline

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "accountline",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "accountlines_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 transaction

Type: belongs_to

Related object: L<Koha::Schema::Result::PaymentsTransaction>

=cut

__PACKAGE__->belongs_to(
  "transaction",
  "Koha::Schema::Result::PaymentsTransaction",
  { transaction_id => "transaction_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-11-19 10:32:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ItfVA6ePztGiqVcJ/VPabQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
