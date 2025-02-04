use utf8;
package Koha::Schema::Result::SipListener;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipListener

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_listeners>

=cut

__PACKAGE__->table("sip_listeners");

=head1 ACCESSORS

=head2 sip_listener_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 client_timeout

  data_type: 'integer'
  is_nullable: 1

=head2 port

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 protocol

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 timeout

  data_type: 'integer'
  is_nullable: 0

=head2 transport

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "sip_listener_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "client_timeout",
  { data_type => "integer", is_nullable => 1 },
  "port",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "protocol",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "timeout",
  { data_type => "integer", is_nullable => 0 },
  "transport",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_listener_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_listener_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<listener_port>

=over 4

=item * L</port>

=back

=cut

__PACKAGE__->add_unique_constraint("listener_port", ["port"]);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-05 13:46:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4SKqHurtcyjF3Vvaq2BAFw


sub koha_objects_class {
    'Koha::SIP2::Listeners';
}

sub koha_object_class {
    'Koha::SIP2::Listener';
}

1;
