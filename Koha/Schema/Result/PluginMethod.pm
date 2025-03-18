use utf8;
package Koha::Schema::Result::PluginMethod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PluginMethod

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<plugin_methods>

=cut

__PACKAGE__->table("plugin_methods");

=head1 ACCESSORS

=head2 plugin_class

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 plugin_method

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "plugin_class",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "plugin_method",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</plugin_class>

=item * L</plugin_method>

=back

=cut

__PACKAGE__->set_primary_key("plugin_class", "plugin_method");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-07-13 12:37:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:koGk3Dh0wkslqYPUqUcK0w

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Plugins::Methods';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Plugins::Method';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
