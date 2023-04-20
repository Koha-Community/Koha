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

unique identifier assigned by Koha

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key linking this message to the borrowers table

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

foreign key linking the message to the branches table

=head2 message_type

  data_type: 'varchar'
  is_nullable: 0
  size: 1

whether the message is for the librarians (L) or the patron (B)

=head2 message

  data_type: 'mediumtext'
  is_nullable: 0

the text of the message

=head2 message_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

the date and time the message was written

=head2 manager_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

creator of message

=head2 patron_read_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date and time the patron dismissed the message

=cut

__PACKAGE__->add_columns(
  "message_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "message_type",
  { data_type => "varchar", is_nullable => 0, size => 1 },
  "message",
  { data_type => "mediumtext", is_nullable => 0 },
  "message_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "manager_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "patron_read_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 manager

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "manager",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "manager_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-20 18:35:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y3cJsv6T0LekoQiyi3T/aA

sub koha_object_class {
    'Koha::Patron::Message';
}
sub koha_objects_class {
    'Koha::Patron::Messages';
}

1;
