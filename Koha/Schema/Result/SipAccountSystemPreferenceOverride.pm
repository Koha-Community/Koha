use utf8;
package Koha::Schema::Result::SipAccountSystemPreferenceOverride;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipAccountSystemPreferenceOverride

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_account_system_preference_overrides>

=cut

__PACKAGE__->table("sip_account_system_preference_overrides");

=head1 ACCESSORS

=head2 sip_account_system_preference_override_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sip_account_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Foreign key to sip_accounts.sip_account_id

=head2 variable

  data_type: 'varchar'
  is_nullable: 0
  size: 80

System preference name

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 80

System preference value

=cut

__PACKAGE__->add_columns(
  "sip_account_system_preference_override_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sip_account_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "variable",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_account_system_preference_override_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_account_system_preference_override_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sip_account>

=over 4

=item * L</sip_account_system_preference_override_id>

=item * L</sip_account_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "sip_account",
  ["sip_account_system_preference_override_id", "sip_account_id"],
);

=head1 RELATIONS

=head2 sip_account

Type: belongs_to

Related object: L<Koha::Schema::Result::SipAccount>

=cut

__PACKAGE__->belongs_to(
  "sip_account",
  "Koha::Schema::Result::SipAccount",
  { sip_account_id => "sip_account_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-05 13:46:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y+MIuEHjSEfNDzlo9oG5+Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head2 koha_objects_class

  Koha Objects class

=cut

sub koha_objects_class {
    'Koha::SIP2::Account::SystemPreferenceOverrides';
}

=head2 koha_object_class

  Koha Object class

=cut

sub koha_object_class {
    'Koha::SIP2::Account::SystemPreferenceOverride';
}

1;
