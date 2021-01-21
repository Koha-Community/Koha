use utf8;
package Koha::Schema::Result::CoverImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CoverImage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<cover_images>

=cut

__PACKAGE__->table("cover_images");

=head1 ACCESSORS

=head2 imagenumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier for the image

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from biblio table to link to biblionumber

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from item table to link to itemnumber

=head2 mimetype

  data_type: 'varchar'
  is_nullable: 0
  size: 15

image type

=head2 imagefile

  data_type: 'mediumblob'
  is_nullable: 0

image file contents

=head2 thumbnail

  data_type: 'mediumblob'
  is_nullable: 0

thumbnail file contents

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

image creation/update time

=cut

__PACKAGE__->add_columns(
  "imagenumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "mimetype",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "imagefile",
  { data_type => "mediumblob", is_nullable => 0 },
  "thumbnail",
  { data_type => "mediumblob", is_nullable => 0 },
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

=item * L</imagenumber>

=back

=cut

__PACKAGE__->set_primary_key("imagenumber");

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Qzy8edw2HP4jZbZRNCOf4A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
