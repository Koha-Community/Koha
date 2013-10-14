use utf8;
package Koha::Schema::Result::Fieldmapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Fieldmapping

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<fieldmapping>

=cut

__PACKAGE__->table("fieldmapping");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 field

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 frameworkcode

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 fieldcode

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 subfieldcode

  data_type: 'char'
  is_nullable: 0
  size: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "field",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "frameworkcode",
  { data_type => "char", default_value => "", is_nullable => 0, size => 4 },
  "fieldcode",
  { data_type => "char", is_nullable => 0, size => 3 },
  "subfieldcode",
  { data_type => "char", is_nullable => 0, size => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x+izN6nqxs+W/g/demOpOg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
