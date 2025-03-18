use utf8;
package Koha::Schema::Result::ErmUserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmUserRole

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_user_roles>

=cut

__PACKAGE__->table("erm_user_roles");

=head1 ACCESSORS

=head2 user_role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

link to the agreement

=head2 license_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

link to the license

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the user

=head2 role

  data_type: 'varchar'
  is_nullable: 0
  size: 80

role of the user

=cut

__PACKAGE__->add_columns(
  "user_role_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "license_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_role_id>

=back

=cut

__PACKAGE__->set_primary_key("user_role_id");

=head1 RELATIONS

=head2 agreement

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->belongs_to(
  "agreement",
  "Koha::Schema::Result::ErmAgreement",
  { agreement_id => "agreement_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 license

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmLicense>

=cut

__PACKAGE__->belongs_to(
  "license",
  "Koha::Schema::Result::ErmLicense",
  { license_id => "license_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 user

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-16 12:23:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HbkogqUuTLQCaUY1VrT6Hw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ERM::UserRole';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ERM::UserRoles';
}

1;
