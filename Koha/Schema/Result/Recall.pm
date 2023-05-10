use utf8;
package Koha::Schema::Result::Recall;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Recall - Information related to recalls in Koha

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<recalls>

=cut

__PACKAGE__->table("recalls");

=head1 ACCESSORS

=head2 recall_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Unique identifier for this recall

=head2 patron_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

Identifier for patron who requested recall

=head2 created_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Date the recall was requested

=head2 biblio_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Identifier for bibliographic record that has been recalled

=head2 pickup_library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

Identifier for recall pickup library

=head2 completed_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Date the recall is completed (fulfilled, cancelled or expired)

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

Notes related to the recall

=head2 priority

  data_type: 'smallint'
  is_nullable: 1

Where in the queue the patron sits

=head2 status

  data_type: 'enum'
  default_value: 'requested'
  extra: {list => ["requested","overdue","waiting","in_transit","cancelled","expired","fulfilled"]}
  is_nullable: 1

Status of recall

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Date and time the recall was last updated

=head2 item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

Identifier for item record that was recalled, if an item-level recall

=head2 waiting_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Date an item was marked as waiting for the patron at the library

=head2 expiration_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Date recall is no longer required, or date recall will expire after waiting on shelf for pickup

=head2 completed

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Flag if recall is old and no longer active, i.e. expired, cancelled or completed

=head2 item_level

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Flag if recall is for a specific item

=cut

__PACKAGE__->add_columns(
  "recall_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patron_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "created_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "biblio_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "pickup_library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "completed_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "priority",
  { data_type => "smallint", is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "requested",
    extra => {
      list => [
        "requested",
        "overdue",
        "waiting",
        "in_transit",
        "cancelled",
        "expired",
        "fulfilled",
      ],
    },
    is_nullable => 1,
  },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "waiting_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "expiration_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "completed",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "item_level",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</recall_id>

=back

=cut

__PACKAGE__->set_primary_key("recall_id");

=head1 RELATIONS

=head2 biblio

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblio",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblio_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 item

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "item_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 patron

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "patron",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "patron_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 pickup_library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "pickup_library",
  "Koha::Schema::Result::Branch",
  { branchcode => "pickup_library_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-10 17:06:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PHc8RtTZ7G02D0ZW4wrPGQ

__PACKAGE__->add_columns(
    '+completed' => { is_boolean => 1 },
    '+item_level' => { is_boolean => 1 },
);

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "pickup_library_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

1;
