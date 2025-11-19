use utf8;
package Koha::Schema::Result::SipSystemPreferenceOverride;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipSystemPreferenceOverride

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_system_preference_overrides>

=cut

__PACKAGE__->table("sip_system_preference_overrides");

=head1 ACCESSORS

=head2 sip_system_preference_override_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

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
  "sip_system_preference_override_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "variable",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_system_preference_override_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_system_preference_override_id");


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-10 10:27:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:szyNGurH+wJBItdnYfAoRA

=head2 koha_objects_class

  Koha Objects class

=cut

sub koha_objects_class {
    'Koha::SIP2::SystemPreferenceOverrides';
}

=head2 koha_object_class

  Koha Object class

=cut

sub koha_object_class {
    'Koha::SIP2::SystemPreferenceOverride';
}

1;
