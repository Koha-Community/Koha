package Koha::Schema::Result::Course;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Course

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
  size: 20

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
  size: 20

=head2 staff_note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 public_note

  data_type: 'mediumtext'
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
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "course_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "department",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "course_number",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "section",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "course_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "term",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "staff_note",
  { data_type => "mediumtext", is_nullable => 1 },
  "public_note",
  { data_type => "mediumtext", is_nullable => 1 },
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
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SN5SfQi+SbfPr069wck64w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
