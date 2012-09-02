package Koha::Schema::Result::MessageTransportType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::MessageTransportType

=cut

__PACKAGE__->table("message_transport_types");

=head1 ACCESSORS

=head2 message_transport_type

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "message_transport_type",
  { data_type => "varchar", is_nullable => 0, size => 20 },
);
__PACKAGE__->set_primary_key("message_transport_type");

=head1 RELATIONS

=head2 borrower_message_transport_preferences

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerMessageTransportPreference>

=cut

__PACKAGE__->has_many(
  "borrower_message_transport_preferences",
  "Koha::Schema::Result::BorrowerMessageTransportPreference",
  {
    "foreign.message_transport_type" => "self.message_transport_type",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 message_queues

Type: has_many

Related object: L<Koha::Schema::Result::MessageQueue>

=cut

__PACKAGE__->has_many(
  "message_queues",
  "Koha::Schema::Result::MessageQueue",
  {
    "foreign.message_transport_type" => "self.message_transport_type",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 message_transports

Type: has_many

Related object: L<Koha::Schema::Result::MessageTransport>

=cut

__PACKAGE__->has_many(
  "message_transports",
  "Koha::Schema::Result::MessageTransport",
  {
    "foreign.message_transport_type" => "self.message_transport_type",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mEnlVv5CZ+YeZCHiOlk45g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
