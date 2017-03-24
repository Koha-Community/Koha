use utf8;
package Koha::Schema::Result::PermissionModule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PermissionModule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<permission_modules>

=cut

__PACKAGE__->table("permission_modules");

=head1 ACCESSORS

=head2 permission_module_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 module

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "permission_module_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "module",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</permission_module_id>

=back

=cut

__PACKAGE__->set_primary_key("permission_module_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<module>

=over 4

=item * L</module>

=back

=cut

__PACKAGE__->add_unique_constraint("module", ["module"]);

=head1 RELATIONS

=head2 borrower_permissions

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerPermission>

=cut

__PACKAGE__->has_many(
  "borrower_permissions",
  "Koha::Schema::Result::BorrowerPermission",
  { "foreign.permission_module_id" => "self.permission_module_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 permissions

Type: has_many

Related object: L<Koha::Schema::Result::Permission>

=cut

__PACKAGE__->has_many(
  "permissions",
  "Koha::Schema::Result::Permission",
  { "foreign.module" => "self.module" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-08-03 18:53:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0p9fkT+XinNSQXJa/egQPw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;