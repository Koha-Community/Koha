use utf8;
package Koha::Schema::Result::ColumnsSetting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ColumnsSetting

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<columns_settings>

=cut

__PACKAGE__->table("columns_settings");

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

=head2 columnname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 cannot_be_toggled

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 is_hidden

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "module",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "page",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "tablename",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "columnname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "cannot_be_toggled",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "is_hidden",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</module>

=item * L</page>

=item * L</tablename>

=item * L</columnname>

=back

=cut

__PACKAGE__->set_primary_key("module", "page", "tablename", "columnname");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-07 12:11:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:s4Zkf15c4v0RJyb1S5UTPA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
