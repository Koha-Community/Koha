use utf8;
package Koha::Schema::Result::OverduerulesTransportType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OverduerulesTransportType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<overduerules_transport_types>

=cut

__PACKAGE__->table("overduerules_transport_types");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 letternumber

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 message_transport_type

  data_type: 'varchar'
  default_value: 'email'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 overduerules_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "letternumber",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "message_transport_type",
  {
    data_type => "varchar",
    default_value => "email",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 20,
  },
  "overduerules_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 overduerule

Type: belongs_to

Related object: L<Koha::Schema::Result::Overduerule>

=cut

__PACKAGE__->belongs_to(
  "overduerule",
  "Koha::Schema::Result::Overduerule",
  { overduerules_id => "overduerules_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-03-31 15:44:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GV2VZ1kIA9Fl8pQd0qkrjg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
