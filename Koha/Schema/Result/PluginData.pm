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

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "plugin_class",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "plugin_key",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "plugin_value",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</plugin_class>

=item * L</plugin_key>

=back

=cut

__PACKAGE__->set_primary_key("plugin_class", "plugin_key");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g4MbnMszG6BGSG0vHxWQig


=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Plugins::Datas';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Plugins::Data';
}

1;
