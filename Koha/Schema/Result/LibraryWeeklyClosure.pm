use utf8;
package Koha::Schema::Result::LibraryWeeklyClosure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LibraryWeeklyClosure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<library_weekly_closures>

=cut

__PACKAGE__->table("library_weekly_closures");

=head1 ACCESSORS

=head2 library_weekly_closure_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier

=head2 library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

foreign key from the branches table

=head2 weekday

  data_type: 'smallint'
  is_nullable: 0

day of the week (0=Sunday, 1=Monday, etc)

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

title of this closing

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

description for this closing

=cut

__PACKAGE__->add_columns(
  "library_weekly_closure_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "weekday",
  { data_type => "smallint", is_nullable => 0 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</library_weekly_closure_id>

=back

=cut

__PACKAGE__->set_primary_key("library_weekly_closure_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<library_id_weekday>

=over 4

=item * L</library_id>

=item * L</weekday>

=back

=cut

__PACKAGE__->add_unique_constraint("library_id_weekday", ["library_id", "weekday"]);

=head1 RELATIONS

=head2 library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-04-08 18:44:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2DqS0FAKqaZrpqCNlJNYaw

=head2 koha_objects_class

=cut

sub koha_objects_class {
    'Koha::Calendar::WeeklyClosures';
}

=head2 koha_object_class

=cut

sub koha_object_class {
    'Koha::Calendar::WeeklyClosure';
}

1;
