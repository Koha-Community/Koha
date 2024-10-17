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

=head2 default_save_state

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 default_save_state_search

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

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
  "default_save_state",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "default_save_state_search",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</module>

=item * L</page>

=item * L</tablename>

=back

=cut

__PACKAGE__->set_primary_key("module", "page", "tablename");


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-10-03 09:24:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+IhbaYydX2NWPTXYCazrWg

__PACKAGE__->add_columns(
    '+default_save_state'        => { is_boolean => 1 },
    '+default_save_state_search' => { is_boolean => 1 },
);

1;
