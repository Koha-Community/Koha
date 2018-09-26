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

=head2 branch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 proccode

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 value

  data_type: 'double precision'
  is_nullable: 1
  size: [16,4]

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 other

  data_type: 'longtext'
  is_nullable: 1

=head2 usercode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 1

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

=head2 associatedborrower

  data_type: 'integer'
  is_nullable: 1

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

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
  "proccode",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "value",
  { data_type => "double precision", is_nullable => 1, size => [16, 4] },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "other",
  { data_type => "longtext", is_nullable => 1 },
  "usercode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "itemnumber",
  { data_type => "integer", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "borrowernumber",
  { data_type => "integer", is_nullable => 1 },
  "associatedborrower",
  { data_type => "integer", is_nullable => 1 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-09-26 16:15:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OECp3uSP488L8TUoS1HseQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
