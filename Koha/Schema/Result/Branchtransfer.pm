use utf8;
package Koha::Schema::Result::Branchtransfer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Branchtransfer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<branchtransfers>

=cut

__PACKAGE__->table("branchtransfers");

=head1 ACCESSORS

=head2 branchtransfer_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 itemnumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

the itemnumber that it is in transit (items.itemnumber)

=head2 daterequested

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

the date the transfer was requested

=head2 datesent

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date the transfer was initialized

=head2 frombranch

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

the branch the transfer is coming from

=head2 datearrived

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date the transfer arrived at its destination

=head2 datecancelled

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date the transfer was cancelled

=head2 tobranch

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

the branch the transfer was going to

=head2 comments

  data_type: 'longtext'
  is_nullable: 1

any comments related to the transfer

=head2 reason

  data_type: 'enum'
  extra: {list => ["Manual","StockrotationAdvance","StockrotationRepatriation","ReturnToHome","ReturnToHolding","RotatingCollection","Reserve","LostReserve","CancelReserve","TransferCancellation","Recall","RecallCancellation"]}
  is_nullable: 1

what triggered the transfer

=head2 cancellation_reason

  data_type: 'enum'
  extra: {list => ["Manual","StockrotationAdvance","StockrotationRepatriation","ReturnToHome","ReturnToHolding","RotatingCollection","Reserve","LostReserve","CancelReserve","ItemLost","WrongTransfer","RecallCancellation"]}
  is_nullable: 1

what triggered the transfer cancellation

=cut

__PACKAGE__->add_columns(
  "branchtransfer_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "itemnumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "daterequested",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "datesent",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "frombranch",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "datearrived",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "datecancelled",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "tobranch",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "comments",
  { data_type => "longtext", is_nullable => 1 },
  "reason",
  {
    data_type => "enum",
    extra => {
      list => [
        "Manual",
        "StockrotationAdvance",
        "StockrotationRepatriation",
        "ReturnToHome",
        "ReturnToHolding",
        "RotatingCollection",
        "Reserve",
        "LostReserve",
        "CancelReserve",
        "TransferCancellation",
        "Recall",
        "RecallCancellation",
      ],
    },
    is_nullable => 1,
  },
  "cancellation_reason",
  {
    data_type => "enum",
    extra => {
      list => [
        "Manual",
        "StockrotationAdvance",
        "StockrotationRepatriation",
        "ReturnToHome",
        "ReturnToHolding",
        "RotatingCollection",
        "Reserve",
        "LostReserve",
        "CancelReserve",
        "ItemLost",
        "WrongTransfer",
        "RecallCancellation",
      ],
    },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchtransfer_id>

=back

=cut

__PACKAGE__->set_primary_key("branchtransfer_id");

=head1 RELATIONS

=head2 frombranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "frombranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "frombranch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
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

=head2 tobranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "tobranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "tobranch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-03 16:48:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BkhtfptiDqKKSv/hmCQy3w

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Item::Transfer';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Item::Transfers';
}

1;
