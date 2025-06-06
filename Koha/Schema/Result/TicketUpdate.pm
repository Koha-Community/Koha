use utf8;
package Koha::Schema::Result::TicketUpdate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::TicketUpdate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<ticket_updates>

=cut

__PACKAGE__->table("ticket_updates");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 ticket_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

id of catalog ticket the update relates to

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

id of the user who logged the update

=head2 assignee_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

id of the user who this ticket was assigned to at this update

=head2 public

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

boolean flag to denote whether this update is public

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time this update was logged

=head2 message

  data_type: 'text'
  is_nullable: 0

update message content

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 80

status of ticket at this update

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "ticket_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "assignee_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "public",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "message",
  { data_type => "text", is_nullable => 0 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 assignee

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "assignee",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "assignee_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 ticket

Type: belongs_to

Related object: L<Koha::Schema::Result::Ticket>

=cut

__PACKAGE__->belongs_to(
  "ticket",
  "Koha::Schema::Result::Ticket",
  { id => "ticket_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-05-02 11:36:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yfQ97AZ3ZYRI5uUndgLKMA

__PACKAGE__->add_columns( '+public' => { is_boolean => 1 }, );

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Ticket::Update';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Ticket::Updates';
}

1;
