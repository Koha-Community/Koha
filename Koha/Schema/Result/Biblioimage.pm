use utf8;
package Koha::Schema::Result::Biblioimage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Biblioimage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblioimages>

=cut

__PACKAGE__->table("biblioimages");

=head1 ACCESSORS

=head2 imagenumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 mimetype

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 imagefile

  data_type: 'mediumblob'
  is_nullable: 0

=head2 thumbnail

  data_type: 'mediumblob'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "imagenumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "mimetype",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "imagefile",
  { data_type => "mediumblob", is_nullable => 0 },
  "thumbnail",
  { data_type => "mediumblob", is_nullable => 0 },
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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WdDuaUrR0IC6+8jJwlev6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
