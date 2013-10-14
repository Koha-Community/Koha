use utf8;
package Koha::Schema::Result::PluginData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PluginData

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<plugin_data>

=cut

__PACKAGE__->table("plugin_data");

=head1 ACCESSORS

=head2 plugin_class

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 plugin_key

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 plugin_value

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "plugin_class",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "plugin_key",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "plugin_value",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</plugin_class>

=item * L</plugin_key>

=back

=cut

__PACKAGE__->set_primary_key("plugin_class", "plugin_key");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/incxJUcobgYLR1a9g8cOQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
