use utf8;
package Koha::Schema::Result::MessageQueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MessageQueue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<message_queue>

=cut

__PACKAGE__->table("message_queue");

=head1 ACCESSORS

=head2 message_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 subject

  data_type: 'mediumtext'
  is_nullable: 1

=head2 content

  data_type: 'mediumtext'
  is_nullable: 1

=head2 metadata

  data_type: 'mediumtext'
  is_nullable: 1

=head2 letter_code

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 message_transport_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 status

  data_type: 'enum'
  default_value: 'pending'
  extra: {list => ["sent","pending","failed","deleted"]}
  is_nullable: 0

=head2 time_queued

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 to_address

  data_type: 'longtext'
  is_nullable: 1

=head2 from_address

  data_type: 'longtext'
  is_nullable: 1

=head2 content_type

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "message_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "subject",
  { data_type => "mediumtext", is_nullable => 1 },
  "content",
  { data_type => "mediumtext", is_nullable => 1 },
  "metadata",
  { data_type => "mediumtext", is_nullable => 1 },
  "letter_code",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "message_transport_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "status",
  {
    data_type => "enum",
    default_value => "pending",
    extra => { list => ["sent", "pending", "failed", "deleted"] },
    is_nullable => 0,
  },
  "time_queued",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "to_address",
  { data_type => "longtext", is_nullable => 1 },
  "from_address",
  { data_type => "longtext", is_nullable => 1 },
  "content_type",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</message_id>

=back

=cut

__PACKAGE__->set_primary_key("message_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 message_transport_type

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageTransportType>

=cut

__PACKAGE__->belongs_to(
  "message_transport_type",
  "Koha::Schema::Result::MessageTransportType",
  { message_transport_type => "message_transport_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9u39S/GLtZwnZGp+xcZOBA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
