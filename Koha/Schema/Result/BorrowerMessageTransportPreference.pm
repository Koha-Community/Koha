use utf8;
package Koha::Schema::Result::BorrowerMessageTransportPreference;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerMessageTransportPreference

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_message_transport_preferences>

=cut

__PACKAGE__->table("borrower_message_transport_preferences");

=head1 ACCESSORS

=head2 borrower_message_preference_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 message_transport_type

  data_type: 'varchar'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "borrower_message_preference_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "message_transport_type",
  {
    data_type => "varchar",
    default_value => 0,
    is_foreign_key => 1,
    is_nullable => 0,
    size => 20,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrower_message_preference_id>

=item * L</message_transport_type>

=back

=cut

__PACKAGE__->set_primary_key("borrower_message_preference_id", "message_transport_type");

=head1 RELATIONS

=head2 borrower_message_preference

Type: belongs_to

Related object: L<Koha::Schema::Result::BorrowerMessagePreference>

=cut

__PACKAGE__->belongs_to(
  "borrower_message_preference",
  "Koha::Schema::Result::BorrowerMessagePreference",
  {
    borrower_message_preference_id => "borrower_message_preference_id",
  },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 message_transport_type

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageTransportType>

=cut

__PACKAGE__->belongs_to(
  "message_transport_type",
  "Koha::Schema::Result::MessageTransportType",
  { message_transport_type => "message_transport_type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yHKWBur//GdtTL5IdjcgIg


# You can replace this text with custom content, and it will be preserved on regeneration

sub koha_object_class {
  'Koha::Patron::MessagePreference::Transport::Preference';
}
sub koha_objects_class {
  'Koha::Patron::MessagePreference::Transport::Preferences';
}

1;
