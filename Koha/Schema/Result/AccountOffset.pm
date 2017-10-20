use utf8;
package Koha::Schema::Result::AccountOffset;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountOffset

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_offsets>

=cut

__PACKAGE__->table("account_offsets");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 credit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 debit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 amount

  data_type: 'decimal'
  is_nullable: 0
  size: [26,6]

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "credit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "debit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "amount",
  { data_type => "decimal", is_nullable => 0, size => [26, 6] },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 credit

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "credit",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "credit_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 debit

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "debit",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "debit_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 type

Type: belongs_to

Related object: L<Koha::Schema::Result::AccountOffsetType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "Koha::Schema::Result::AccountOffsetType",
  { type => "type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-10-20 16:27:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tPPrIug2c7PbDO7LCxCJAA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
