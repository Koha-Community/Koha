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
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "license_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-01 07:44:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RkK5cQWFEmcrDioAfjOVWQ

sub koha_object_class {
    'Koha::ERM::Agreement::UserRole';
}
sub koha_objects_class {
    'Koha::ERM::Agreement::UserRoles';
}

1;
