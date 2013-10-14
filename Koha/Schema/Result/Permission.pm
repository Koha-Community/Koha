use utf8;
package Koha::Schema::Result::Permission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Permission

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<permissions>

=cut

__PACKAGE__->table("permissions");

=head1 ACCESSORS

=head2 module_bit

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 code

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "module_bit",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</module_bit>

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("module_bit", "code");

=head1 RELATIONS

=head2 module_bit

Type: belongs_to

Related object: L<Koha::Schema::Result::Userflag>

=cut

__PACKAGE__->belongs_to(
  "module_bit",
  "Koha::Schema::Result::Userflag",
  { bit => "module_bit" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user_permissions

Type: has_many

Related object: L<Koha::Schema::Result::UserPermission>

=cut

__PACKAGE__->has_many(
  "user_permissions",
  "Koha::Schema::Result::UserPermission",
  {
    "foreign.code"       => "self.code",
    "foreign.module_bit" => "self.module_bit",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ut3lzlxoPPoIIwmhJViV1Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
