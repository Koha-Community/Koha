use utf8;
package Koha::Schema::Result::CourseReserve;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CourseReserve

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<course_reserves>

=cut

__PACKAGE__->table("course_reserves");

=head1 ACCESSORS

=head2 cr_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 course_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ci_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 staff_note

  data_type: 'longtext'
  is_nullable: 1

=head2 public_note

  data_type: 'longtext'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cr_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "course_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ci_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "staff_note",
  { data_type => "longtext", is_nullable => 1 },
  "public_note",
  { data_type => "longtext", is_nullable => 1 },
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

=item * L</cr_id>

=back

=cut

__PACKAGE__->set_primary_key("cr_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<pseudo_key>

=over 4

=item * L</course_id>

=item * L</ci_id>

=back

=cut

__PACKAGE__->add_unique_constraint("pseudo_key", ["course_id", "ci_id"]);

=head1 RELATIONS

=head2 ci

Type: belongs_to

Related object: L<Koha::Schema::Result::CourseItem>

=cut

__PACKAGE__->belongs_to(
  "ci",
  "Koha::Schema::Result::CourseItem",
  { ci_id => "ci_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 course

Type: belongs_to

Related object: L<Koha::Schema::Result::Course>

=cut

__PACKAGE__->belongs_to(
  "course",
  "Koha::Schema::Result::Course",
  { course_id => "course_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8SDdUrbxKuAwp6rgn85RmA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
