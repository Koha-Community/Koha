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

=head2 permission_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 module

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "permission_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "module",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</permission_id>

=back

=cut

__PACKAGE__->set_primary_key("permission_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<code>

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->add_unique_constraint("code", ["code"]);

=head1 RELATIONS

=head2 borrower_permissions

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerPermission>

=cut

__PACKAGE__->has_many(
  "borrower_permissions",
  "Koha::Schema::Result::BorrowerPermission",
  { "foreign.permission_id" => "self.permission_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 module

Type: belongs_to

Related object: L<Koha::Schema::Result::PermissionModule>

=cut

__PACKAGE__->belongs_to(
  "module",
  "Koha::Schema::Result::PermissionModule",
  { module => "module" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tcIPevxrQLlsqlHRBnKVfw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
