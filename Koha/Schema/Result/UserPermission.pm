use utf8;
package Koha::Schema::Result::UserPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::UserPermission

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_permissions>

=cut

__PACKAGE__->table("user_permissions");

=head1 ACCESSORS

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 module_bit

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 code

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "borrowernumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "module_bit",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "code",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 64 },
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
  { code => "code", module_bit => "module_bit" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9dMAYxSmVQ1cVKxmnMiMkg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
