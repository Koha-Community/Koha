use utf8;
package Koha::Schema::Result::VetumaTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::VetumaTransaction

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vetuma_transaction>

=cut

__PACKAGE__->table("vetuma_transaction");

=head1 ACCESSORS

=head2 transaction_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 request_timestamp

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 response_timestamp

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 ref

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 trid

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 response_so

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 payid

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 paid

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "transaction_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "request_timestamp",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "response_timestamp",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "ref",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "trid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "response_so",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "payid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "paid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</transaction_id>

=back

=cut

__PACKAGE__->set_primary_key("transaction_id");

=head1 RELATIONS

=head2 vetuma_transaction_accountlines_links

Type: has_many

Related object: L<Koha::Schema::Result::VetumaTransactionAccountlinesLink>

=cut

__PACKAGE__->has_many(
  "vetuma_transaction_accountlines_links",
  "Koha::Schema::Result::VetumaTransactionAccountlinesLink",
  { "foreign.transaction_id" => "self.transaction_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 accountlines

Type: many_to_many

Composing rels: L</vetuma_transaction_accountlines_links> -> accountline

=cut

__PACKAGE__->many_to_many(
  "accountlines",
  "vetuma_transaction_accountlines_links",
  "accountline",
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-12-28 11:32:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rqR/U4TldN0+ctatl+rBYA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
