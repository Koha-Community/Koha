use utf8;
package Koha::Schema::Result::Message;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Message

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<messages>

=cut

__PACKAGE__->table("messages");

=head1 ACCESSORS

=head2 message_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 message_type

  data_type: 'varchar'
  is_nullable: 0
  size: 1

=head2 message

  data_type: 'text'
  is_nullable: 0

=head2 message_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "message_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "message_type",
  { data_type => "varchar", is_nullable => 0, size => 1 },
  "message",
  { data_type => "text", is_nullable => 0 },
  "message_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</message_id>

=back

=cut

__PACKAGE__->set_primary_key("message_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iq+Uo9eMnkDgUQsRR6VFUA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
