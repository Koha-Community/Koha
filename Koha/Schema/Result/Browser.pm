use utf8;
package Koha::Schema::Result::Browser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Browser

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<browser>

=cut

__PACKAGE__->table("browser");

=head1 ACCESSORS

=head2 level

  data_type: 'integer'
  is_nullable: 0

=head2 classification

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 number

  data_type: 'bigint'
  is_nullable: 0

=head2 endnode

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "level",
  { data_type => "integer", is_nullable => 0 },
  "classification",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "number",
  { data_type => "bigint", is_nullable => 0 },
  "endnode",
  { data_type => "tinyint", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eMoAXr+/JrrwEjJ3dRRwoA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
