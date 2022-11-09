use utf8;
package Koha::Schema::Result::TmpHoldsqueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::TmpHoldsqueue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tmp_holdsqueue>

=cut

__PACKAGE__->table("tmp_holdsqueue");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 barcode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 surname

  data_type: 'longtext'
  is_nullable: 0

=head2 firstname

  data_type: 'mediumtext'
  is_nullable: 1

=head2 phone

  data_type: 'mediumtext'
  is_nullable: 1

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 cardnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 reservedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 title

  data_type: 'longtext'
  is_nullable: 1

=head2 itemcallnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 holdingbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 pickbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 item_level_request

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time this entry as added/last updated

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "barcode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "surname",
  { data_type => "longtext", is_nullable => 0 },
  "firstname",
  { data_type => "mediumtext", is_nullable => 1 },
  "phone",
  { data_type => "mediumtext", is_nullable => 1 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "cardnumber",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "reservedate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "title",
  { data_type => "longtext", is_nullable => 1 },
  "itemcallnumber",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "holdingbranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "pickbranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "item_level_request",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-04 22:42:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RdIrLi+vbzj3ab/UP7e9pw

__PACKAGE__->add_columns(
    '+item_level_request' => { is_boolean => 1 }
);

sub koha_object_class {
    'Koha::HoldsQueueItem';
}

sub koha_objects_class {
    'Koha::HoldsQueueItems';
}

1;
