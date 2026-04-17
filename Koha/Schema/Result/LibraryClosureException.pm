use utf8;
package Koha::Schema::Result::LibraryClosureException;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LibraryClosureException

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<library_closure_exceptions>

=cut

__PACKAGE__->table("library_closure_exceptions");

=head1 ACCESSORS

=head2 library_closure_exception_id

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

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

date of the exception (library is open despite a closure rule)

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

title for this exception

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

description of this exception

=cut

__PACKAGE__->add_columns(
  "library_closure_exception_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</library_closure_exception_id>

=back

=cut

__PACKAGE__->set_primary_key("library_closure_exception_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<library_id_date>

=over 4

=item * L</library_id>

=item * L</date>

=back

=cut

__PACKAGE__->add_unique_constraint("library_id_date", ["library_id", "date"]);

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Yocq8npRLy1r8xhR65EBfQ

=head2 koha_objects_class

=cut

sub koha_objects_class {
    'Koha::Library::Calendar::Exceptions';
}

=head2 koha_object_class

=cut

sub koha_object_class {
    'Koha::Library::Calendar::Exception';
}

1;
