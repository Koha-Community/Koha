use utf8;
package Koha::Schema::Result::SipServerParam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipServerParam

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_server_params>

=cut

__PACKAGE__->table("sip_server_params");

=head1 ACCESSORS

=head2 sip_server_param_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 key

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "sip_server_param_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "key",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_server_param_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_server_param_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<server_param_key>

=over 4

=item * L</key>

=back

=cut

__PACKAGE__->add_unique_constraint("server_param_key", ["key"]);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-07 16:23:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VU5dn7xlVS8ZZKB1i2V6oQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
