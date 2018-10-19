use utf8;
package Koha::Schema::Result::Holding;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Holding

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<holdings>

=cut

__PACKAGE__->table("holdings");

=head1 ACCESSORS

=head2 holding_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 biblioitemnumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 frameworkcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 holdingbranch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 callnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 suppress

  data_type: 'tinyint'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=head2 datecreated

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 deleted_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "holding_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "biblioitemnumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "frameworkcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
  "holdingbranch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "callnumber",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "suppress",
  { data_type => "tinyint", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
  "datecreated",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "deleted_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</holding_id>

=back

=cut

__PACKAGE__->set_primary_key("holding_id");

=head1 RELATIONS

=head2 biblioitemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblioitem>

=cut

__PACKAGE__->belongs_to(
  "biblioitemnumber",
  "Koha::Schema::Result::Biblioitem",
  { biblioitemnumber => "biblioitemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

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

=head2 holdingbranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "holdingbranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "holdingbranch" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);

=head2 holdings_metadatas

Type: has_many

Related object: L<Koha::Schema::Result::HoldingsMetadata>

=cut

__PACKAGE__->has_many(
  "holdings_metadatas",
  "Koha::Schema::Result::HoldingsMetadata",
  { "foreign.holding_id" => "self.holding_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 items

Type: has_many

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items",
  "Koha::Schema::Result::Item",
  { "foreign.holding_id" => "self.holding_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-10-19 09:31:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m9kgiNs7rtk5KNrXWs7WQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
