use utf8;
package Koha::Schema::Result::Overduerule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Overduerule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<overduerules>

=cut

__PACKAGE__->table("overduerules");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 delay1

  data_type: 'integer'
  is_nullable: 1

=head2 letter1

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 debarred1

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 1

=head2 delay2

  data_type: 'integer'
  is_nullable: 1

=head2 debarred2

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 1

=head2 letter2

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 delay3

  data_type: 'integer'
  is_nullable: 1

=head2 letter3

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 debarred3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "categorycode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "delay1",
  { data_type => "integer", is_nullable => 1 },
  "letter1",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "debarred1",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 1 },
  "delay2",
  { data_type => "integer", is_nullable => 1 },
  "debarred2",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 1 },
  "letter2",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "delay3",
  { data_type => "integer", is_nullable => 1 },
  "letter3",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "debarred3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=item * L</categorycode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode", "categorycode");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hP/0cV6iad2dz8kIhCYFjw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
