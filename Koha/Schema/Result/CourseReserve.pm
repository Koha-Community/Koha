package Koha::Schema::Result::CourseReserve;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::CourseReserve

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
  is_nullable: 0

=head2 staff_note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 public_note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cr_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "course_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ci_id",
  { data_type => "integer", is_nullable => 0 },
  "staff_note",
  { data_type => "mediumtext", is_nullable => 1 },
  "public_note",
  { data_type => "mediumtext", is_nullable => 1 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("cr_id");
__PACKAGE__->add_unique_constraint("pseudo_key", ["course_id", "ci_id"]);

=head1 RELATIONS

=head2 course

Type: belongs_to

Related object: L<Koha::Schema::Result::Course>

=cut

__PACKAGE__->belongs_to(
  "course",
  "Koha::Schema::Result::Course",
  { course_id => "course_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LUZRTXuhywezgITcSqqDJQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
