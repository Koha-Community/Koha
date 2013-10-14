use utf8;
package Koha::Schema::Result::Accountline;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Accountline

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<accountlines>

=cut

__PACKAGE__->table("accountlines");

=head1 ACCESSORS

=head2 accountlines_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 accountno

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 dispute

  data_type: 'mediumtext'
  is_nullable: 1

=head2 accounttype

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 amountoutstanding

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 lastincrement

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 notify_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 notify_level

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 note

  data_type: 'text'
  is_nullable: 1

=head2 manager_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "accountlines_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "accountno",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "dispute",
  { data_type => "mediumtext", is_nullable => 1 },
  "accounttype",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "amountoutstanding",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "lastincrement",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "notify_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "notify_level",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "note",
  { data_type => "text", is_nullable => 1 },
  "manager_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</accountlines_id>

=back

=cut

__PACKAGE__->set_primary_key("accountlines_id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VLEuOBmnS+xgk7LXAqxtLw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
