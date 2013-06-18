package Koha::Schema::Result::PluginData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::PluginData

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
__PACKAGE__->set_primary_key("plugin_class", "plugin_key");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XC9EptLCJK8QWBHGy1TnPw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
