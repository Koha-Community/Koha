use utf8;
package Koha::Schema::Result::CollectionsTracking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CollectionsTracking

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<collections_tracking>

=cut

__PACKAGE__->table("collections_tracking");

=head1 ACCESSORS

=head2 collections_tracking_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 colId

  accessor: 'col_id'
  data_type: 'integer'
  default_value: 0
  is_nullable: 0

collections.colId

=head2 itemnumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

items.itemnumber

=head2 origin_branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 transfer_branch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 transferred

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 date_added

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "collections_tracking_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "colId",
  {
    accessor      => "col_id",
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 0,
  },
  "itemnumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "origin_branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "transfer_branch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "transferred",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "date_added",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</collections_tracking_id>

=back

=cut

__PACKAGE__->set_primary_key("collections_tracking_id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1M9d/2SYL/onXJ+eaZcgAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
