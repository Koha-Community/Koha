package Koha::Schema::Result::CourseInstructor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::CourseInstructor

=cut

__PACKAGE__->table("course_instructors");

=head1 ACCESSORS

=head2 course_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "course_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("course_id", "borrowernumber");

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

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zPwefIbI2Pz0pX03KpS1eQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
