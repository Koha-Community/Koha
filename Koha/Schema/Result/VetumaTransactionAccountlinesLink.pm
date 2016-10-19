use utf8;
package Koha::Schema::Result::VetumaTransactionAccountlinesLink;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::VetumaTransactionAccountlinesLink

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vetuma_transaction_accountlines_link>

=cut

__PACKAGE__->table("vetuma_transaction_accountlines_link");

=head1 ACCESSORS

=head2 accountlines_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 transaction_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "accountlines_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "transaction_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</accountlines_id>

=item * L</transaction_id>

=back

=cut

__PACKAGE__->set_primary_key("accountlines_id", "transaction_id");

=head1 RELATIONS

=head2 accountline

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "accountline",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "accountlines_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 transaction

Type: belongs_to

Related object: L<Koha::Schema::Result::VetumaTransaction>

=cut

__PACKAGE__->belongs_to(
  "transaction",
  "Koha::Schema::Result::VetumaTransaction",
  { transaction_id => "transaction_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-12-28 11:32:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KBn0cFj4WQ5cOGK6MsPNiA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
