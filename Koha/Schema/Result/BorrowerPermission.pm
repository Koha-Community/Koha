use utf8;
package Koha::Schema::Result::BorrowerPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerPermission

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_permissions>

=cut

__PACKAGE__->table("borrower_permissions");

=head1 ACCESSORS

=head2 borrower_permission_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 permission_module_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 permission_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "borrower_permission_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "permission_module_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "permission_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrower_permission_id>

=back

=cut

__PACKAGE__->set_primary_key("borrower_permission_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<borrowernumber>

=over 4

=item * L</borrowernumber>

=item * L</permission_module_id>

=item * L</permission_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "borrowernumber",
  ["borrowernumber", "permission_module_id", "permission_id"],
);

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 permission

Type: belongs_to

Related object: L<Koha::Schema::Result::Permission>

=cut

__PACKAGE__->belongs_to(
  "permission",
  "Koha::Schema::Result::Permission",
  { permission_id => "permission_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 permission_module

Type: belongs_to

Related object: L<Koha::Schema::Result::PermissionModule>

=cut

__PACKAGE__->belongs_to(
  "permission_module",
  "Koha::Schema::Result::PermissionModule",
  { permission_module_id => "permission_module_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-08-03 18:53:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oeu9FDU0R/YXazuSik1yfA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
