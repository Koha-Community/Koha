use utf8;
package Koha::Schema::Result::Course;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Course

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<courses>

=cut

__PACKAGE__->table("courses");

=head1 ACCESSORS

=head2 course_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 department

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 course_number

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 section

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 course_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 term

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 staff_note

  data_type: 'longtext'
  is_nullable: 1

=head2 public_note

  data_type: 'longtext'
  is_nullable: 1

=head2 students_count

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 enabled

  data_type: 'enum'
  default_value: 'yes'
  extra: {list => ["yes","no"]}
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "course_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "department",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "course_number",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "section",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "course_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "term",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "staff_note",
  { data_type => "longtext", is_nullable => 1 },
  "public_note",
  { data_type => "longtext", is_nullable => 1 },
  "students_count",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "enabled",
  {
    data_type => "enum",
    default_value => "yes",
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

=item * L</course_id>

=back

=cut

__PACKAGE__->set_primary_key("course_id");

=head1 RELATIONS

=head2 course_instructors

Type: has_many

Related object: L<Koha::Schema::Result::CourseInstructor>

=cut

__PACKAGE__->has_many(
  "course_instructors",
  "Koha::Schema::Result::CourseInstructor",
  { "foreign.course_id" => "self.course_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 course_reserves

Type: has_many

Related object: L<Koha::Schema::Result::CourseReserve>

=cut

__PACKAGE__->has_many(
  "course_reserves",
  "Koha::Schema::Result::CourseReserve",
  { "foreign.course_id" => "self.course_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowernumbers

Type: many_to_many

Composing rels: L</course_instructors> -> borrowernumber

=cut

__PACKAGE__->many_to_many("borrowernumbers", "course_instructors", "borrowernumber");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o0EBOuJCHxH5IG/PgsJfxg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
