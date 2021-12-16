use utf8;
package Koha::Schema::Result::TablesSetting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::TablesSetting

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tables_settings>

=cut

__PACKAGE__->table("tables_settings");

=head1 ACCESSORS

=head2 module

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 page

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 tablename

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 default_display_length

  data_type: 'smallint'
  is_nullable: 1

=head2 default_sort_order

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "module",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "page",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "tablename",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "default_display_length",
  { data_type => "smallint", is_nullable => 1 },
  "default_sort_order",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</module>

=item * L</page>

=item * L</tablename>

=back

=cut

__PACKAGE__->set_primary_key("module", "page", "tablename");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-12-16 11:41:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:42x+rSLgXvSZBVLx5mh2ng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
