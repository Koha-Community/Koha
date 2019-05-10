use utf8;
package Koha::Schema::Result::KeyboardShortcut;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::KeyboardShortcut

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<keyboard_shortcuts>

=cut

__PACKAGE__->table("keyboard_shortcuts");

=head1 ACCESSORS

=head2 shortcut_name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 shortcut_keys

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "shortcut_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "shortcut_keys",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</shortcut_name>

=back

=cut

__PACKAGE__->set_primary_key("shortcut_name");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2019-05-10 19:02:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pnxutghDJLyCGVkChuk2rQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
