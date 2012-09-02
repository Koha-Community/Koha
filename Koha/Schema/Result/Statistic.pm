package Koha::Schema::Result::Statistic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Statistic

=cut

__PACKAGE__->table("statistics");

=head1 ACCESSORS

=head2 datetime

  data_type: 'datetime'
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

  data_type: 'mediumtext'
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

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

=head2 associatedborrower

  data_type: 'integer'
  is_nullable: 1

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "datetime",
  { data_type => "datetime", is_nullable => 1 },
  "branch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "proccode",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "value",
  { data_type => "double precision", is_nullable => 1, size => [16, 4] },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "other",
  { data_type => "mediumtext", is_nullable => 1 },
  "usercode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "itemnumber",
  { data_type => "integer", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "borrowernumber",
  { data_type => "integer", is_nullable => 1 },
  "associatedborrower",
  { data_type => "integer", is_nullable => 1 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JYb2c/mWBks4WwV/WDm5RA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
