use utf8;
package Koha::Schema::Result::Recall;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Recall

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

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 recalldate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 cancellationdate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 recallnotes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 priority

  data_type: 'smallint'
  is_nullable: 1

=head2 status

  data_type: 'enum'
  default_value: 'requested'
  extra: {list => ["requested","overdue","waiting","in_transit","cancelled","expired","fulfilled"]}
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 waitingdate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 expirationdate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 old

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 item_level_recall

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "recall_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "recalldate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "biblionumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "cancellationdate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "recallnotes",
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
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "waitingdate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "expirationdate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "old",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "item_level_recall",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</recall_id>

=back

=cut

__PACKAGE__->set_primary_key("recall_id");

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-03-23 19:53:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6DbEjtt5g6QY6VuCqrMleg

__PACKAGE__->add_columns(
    '+completed' => { is_boolean => 1 },
    '+item_level' => { is_boolean => 1 },
);

__PACKAGE__->belongs_to(
  "biblio",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
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
  "patron",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

1;
