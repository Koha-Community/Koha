use utf8;
package Koha::Schema::Result::CourseItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CourseItem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<course_items>

=cut

__PACKAGE__->table("course_items");

=head1 ACCESSORS

=head2 ci_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 itype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 holdingbranch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 enabled

  data_type: 'enum'
  default_value: 'no'
  extra: {list => ["yes","no"]}
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ci_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "itype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "holdingbranch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "enabled",
  {
    data_type => "enum",
    default_value => "no",
    extra => { list => ["yes", "no"] },
    is_nullable => 0,
  },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</ci_id>

=back

=cut

__PACKAGE__->set_primary_key("ci_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<itemnumber>

=over 4

=item * L</itemnumber>

=back

=cut

__PACKAGE__->add_unique_constraint("itemnumber", ["itemnumber"]);

=head1 RELATIONS

=head2 course_reserves

Type: has_many

Related object: L<Koha::Schema::Result::CourseReserve>

=cut

__PACKAGE__->has_many(
  "course_reserves",
  "Koha::Schema::Result::CourseReserve",
  { "foreign.ci_id" => "self.ci_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-09-26 16:15:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0hBp2R7AMxgHLLZcG/676w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
