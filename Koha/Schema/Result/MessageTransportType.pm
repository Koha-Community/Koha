use utf8;
package Koha::Schema::Result::MessageTransportType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MessageTransportType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<message_transport_types>

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

=head1 PRIMARY KEY

=over 4

=item * L</message_transport_type>

=back

=cut

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

=head2 letters

Type: has_many

Related object: L<Koha::Schema::Result::Letter>

=cut

__PACKAGE__->has_many(
  "letters",
  "Koha::Schema::Result::Letter",
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

=head2 overduerules_transport_types

Type: has_many

Related object: L<Koha::Schema::Result::OverduerulesTransportType>

=cut

__PACKAGE__->has_many(
  "overduerules_transport_types",
  "Koha::Schema::Result::OverduerulesTransportType",
  {
    "foreign.message_transport_type" => "self.message_transport_type",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_message_preferences

Type: many_to_many

Composing rels: L</borrower_message_transport_preferences> -> borrower_message_preference

=cut

__PACKAGE__->many_to_many(
  "borrower_message_preferences",
  "borrower_message_transport_preferences",
  "borrower_message_preference",
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-05-02 18:04:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YpzL/dxDWq//5vqXfvHoVQ


# You can replace this text with custom content, and it will be preserved on regeneration

sub koha_object_class {
  'Koha::Patron::Message::Transport::Type';
}
sub koha_objects_class {
  'Koha::Patron::Message::Transport::Types';
}

1;
