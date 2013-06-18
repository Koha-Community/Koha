package Koha::Schema::Result::OldReserve;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::OldReserve

=cut

__PACKAGE__->table("old_reserves");

=head1 ACCESSORS

=head2 reserve_id

  data_type: 'integer'
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 reservedate

  data_type: 'date'
  is_nullable: 1

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 constrainttype

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 notificationdate

  data_type: 'date'
  is_nullable: 1

=head2 reminderdate

  data_type: 'date'
  is_nullable: 1

=head2 cancellationdate

  data_type: 'date'
  is_nullable: 1

=head2 reservenotes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 priority

  data_type: 'smallint'
  is_nullable: 1

=head2 found

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 waitingdate

  data_type: 'date'
  is_nullable: 1

=head2 expirationdate

  data_type: 'date'
  is_nullable: 1

=head2 lowestpriority

  data_type: 'tinyint'
  is_nullable: 0

=head2 suspend

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 suspend_until

  data_type: 'datetime'
  is_nullable: 1

=head2 maxpickupdate

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "reserve_id",
  { data_type => "integer", is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "reservedate",
  { data_type => "date", is_nullable => 1 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "constrainttype",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "notificationdate",
  { data_type => "date", is_nullable => 1 },
  "reminderdate",
  { data_type => "date", is_nullable => 1 },
  "cancellationdate",
  { data_type => "date", is_nullable => 1 },
  "reservenotes",
  { data_type => "mediumtext", is_nullable => 1 },
  "priority",
  { data_type => "smallint", is_nullable => 1 },
  "found",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "waitingdate",
  { data_type => "date", is_nullable => 1 },
  "expirationdate",
  { data_type => "date", is_nullable => 1 },
  "lowestpriority",
  { data_type => "tinyint", is_nullable => 0 },
  "suspend",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "suspend_until",
  { data_type => "datetime", is_nullable => 1 },
  "maxpickupdate",
  { data_type => "date", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("reserve_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ni1RNxdeOoypM+GwYu1vAQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
