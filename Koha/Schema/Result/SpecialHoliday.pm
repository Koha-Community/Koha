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

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 day

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 month

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 year

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 isexception

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9Qc6VbOUqX83upThUC//oA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
