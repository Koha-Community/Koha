use utf8;
package Koha::Schema::Result::CreatorImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CreatorImage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<creator_images>

=cut

__PACKAGE__->table("creator_images");

=head1 ACCESSORS

=head2 image_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 imagefile

  data_type: 'mediumblob'
  is_nullable: 1

=head2 image_name

  data_type: 'char'
  default_value: 'DEFAULT'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "image_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "imagefile",
  { data_type => "mediumblob", is_nullable => 1 },
  "image_name",
  {
    data_type => "char",
    default_value => "DEFAULT",
    is_nullable => 0,
    size => 20,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</image_id>

=back

=cut

__PACKAGE__->set_primary_key("image_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<image_name_index>

=over 4

=item * L</image_name>

=back

=cut

__PACKAGE__->add_unique_constraint("image_name_index", ["image_name"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:veljpS1CT3wfNDilccroGg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
