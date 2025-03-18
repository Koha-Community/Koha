use utf8;
package Koha::Schema::Result::Patronimage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Patronimage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<patronimage>

=cut

__PACKAGE__->table("patronimage");

=head1 ACCESSORS

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the borrowernumber of the patron this image is attached to (borrowers.borrowernumber)

=head2 mimetype

  data_type: 'varchar'
  is_nullable: 0
  size: 15

the format of the image (png, jpg, etc)

=head2 imagefile

  data_type: 'mediumblob'
  is_nullable: 0

the image

=cut

__PACKAGE__->add_columns(
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "mimetype",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "imagefile",
  { data_type => "mediumblob", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrowernumber>

=back

=cut

__PACKAGE__->set_primary_key("borrowernumber");

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DWbMgbxlYcZhGF1YK9fDIA

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::Image';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::Images';
}

1;
