use utf8;
package Koha::Schema::Result::PendingOfflineOperation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PendingOfflineOperation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<pending_offline_operations>

=cut

__PACKAGE__->table("pending_offline_operations");

=head1 ACCESSORS

=head2 operationid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 userid

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 action

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 barcode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 cardnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=cut

__PACKAGE__->add_columns(
  "operationid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "userid",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "branchcode",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "action",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "barcode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "cardnumber",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
);

=head1 PRIMARY KEY

=over 4

=item * L</operationid>

=back

=cut

__PACKAGE__->set_primary_key("operationid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hU8G7b8om2DKesFTwuGrJA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
