use utf8;
package Koha::Schema::Result::IdentityProviderDomain;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::IdentityProviderDomain

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<identity_provider_domains>

=cut

__PACKAGE__->table("identity_provider_domains");

=head1 ACCESSORS

=head2 identity_provider_domain_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique key, used to identify providers domain

=head2 identity_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Reference to provider

=head2 domain

  data_type: 'varchar'
  is_nullable: 1
  size: 100

Domain name. If null means all domains

=head2 auto_register

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Allow user auto register

=head2 update_on_auth

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Update user data on auth login

=head2 default_library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

Default library to create user if auto register is enabled

=head2 default_category_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

Default category to create user if auto register is enabled

=head2 allow_opac

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

Allow provider from opac interface

=head2 allow_staff

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Allow provider from staff interface

=cut

__PACKAGE__->add_columns(
  "identity_provider_domain_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "identity_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "domain",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "auto_register",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "update_on_auth",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "default_library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "default_category_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "allow_opac",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "allow_staff",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</identity_provider_domain_id>

=back

=cut

__PACKAGE__->set_primary_key("identity_provider_domain_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<identity_provider_id>

=over 4

=item * L</identity_provider_id>

=item * L</domain>

=back

=cut

__PACKAGE__->add_unique_constraint("identity_provider_id", ["identity_provider_id", "domain"]);

=head1 RELATIONS

=head2 default_category

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "default_category",
  "Koha::Schema::Result::Category",
  { categorycode => "default_category_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 default_library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "default_library",
  "Koha::Schema::Result::Branch",
  { branchcode => "default_library_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 identity_provider

Type: belongs_to

Related object: L<Koha::Schema::Result::IdentityProvider>

=cut

__PACKAGE__->belongs_to(
  "identity_provider",
  "Koha::Schema::Result::IdentityProvider",
  { identity_provider_id => "identity_provider_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-08 17:35:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uUnzFzRKWAiYUsmapofXwQ

__PACKAGE__->add_columns(
    '+auto_register'  => { is_boolean => 1 },
    '+update_on_auth' => { is_boolean => 1 },
    '+allow_opac'     => { is_boolean => 1 },
    '+allow_staff'    => { is_boolean => 1 }
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Auth::Identity::Provider::Domain';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Auth::Identity::Provider::Domains';
}

1;
