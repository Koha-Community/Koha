use utf8;
package Koha::Schema::Result::SpecialHoliday;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SpecialHoliday

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<special_holidays>

=cut

__PACKAGE__->table("special_holidays");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

foreign key from the branches table, defines which branch this closing is for

=head2 day

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

day of the month this closing is on

=head2 month

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

month this closing is in

=head2 year

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

year this closing is in

=head2 isexception

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

is this a holiday exception to a repeatable holiday (1 for yes, 0 for no)

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

title for this closing

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

description of this closing

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "day",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "month",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "year",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "isexception",
  { data_type => "smallint", default_value => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H3PUa5HiJKKfdndKXbmJ6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
