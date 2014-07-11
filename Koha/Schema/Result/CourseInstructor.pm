use utf8;
package Koha::Schema::Result::CourseInstructor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CourseInstructor

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<course_instructors>

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

=head1 PRIMARY KEY

=over 4

=item * L</course_id>

=item * L</borrowernumber>

=back

=cut

__PACKAGE__->set_primary_key("course_id", "borrowernumber");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-11 09:26:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7vP3bJ0YA6LEepYOaNg++A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
