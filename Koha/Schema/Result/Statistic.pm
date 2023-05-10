use utf8;
package Koha::Schema::Result::Statistic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Statistic

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<statistics>

=cut

__PACKAGE__->table("statistics");

=head1 ACCESSORS

=head2 datetime

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date and time of the transaction

=head2 branch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

foreign key, branch where the transaction occurred

=head2 value

  data_type: 'double precision'
  is_nullable: 1
  size: [16,4]

monetary value associated with the transaction

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 16

transaction type (localuse, issue, return, renew, writeoff, payment)

=head2 other

  data_type: 'longtext'
  is_nullable: 1

used by SIP

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 1

foreign key from the items table, links transaction to a specific item

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

foreign key from the itemtypes table, links transaction to a specific item type

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

authorized value for the shelving location for this item (MARC21 952$c)

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

foreign key from the borrowers table, links transaction to a specific borrower

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

foreign key from the items table, links transaction to a specific collection code

=head2 categorycode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

foreign key from the borrowers table, links transaction to a specific borrower category

=head2 interface

  data_type: 'varchar'
  is_nullable: 1
  size: 30

the context this action was taken in

=cut

__PACKAGE__->add_columns(
  "datetime",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "branch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "value",
  { data_type => "double precision", is_nullable => 1, size => [16, 4] },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "other",
  { data_type => "longtext", is_nullable => 1 },
  "itemnumber",
  { data_type => "integer", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "borrowernumber",
  { data_type => "integer", is_nullable => 1 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "categorycode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "interface",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-10 17:08:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3mznfs//6bH21hFpyZl7lw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
