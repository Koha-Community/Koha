use utf8;
package Koha::Schema::Result::Ticket;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Ticket

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tickets>

=cut

__PACKAGE__->table("tickets");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 reporter_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

id of the patron who reported the ticket

=head2 reported_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time this ticket was reported

=head2 title

  data_type: 'text'
  is_nullable: 0

ticket title

=head2 body

  data_type: 'text'
  is_nullable: 0

ticket details

=head2 resolver_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

id of the user who resolved the ticket

=head2 resolved_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date and time this ticket was resolved

=head2 biblio_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

id of biblio linked

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "reporter_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "reported_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "title",
  { data_type => "text", is_nullable => 0 },
  "body",
  { data_type => "text", is_nullable => 0 },
  "resolver_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "resolved_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "biblio_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 biblio

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblio",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblio_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 reporter

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "reporter",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "reporter_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 resolver

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "resolver",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "resolver_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 ticket_updates

Type: has_many

Related object: L<Koha::Schema::Result::TicketUpdate>

=cut

__PACKAGE__->has_many(
  "ticket_updates",
  "Koha::Schema::Result::TicketUpdate",
  { "foreign.ticket_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-24 21:15:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0Nm+y1BHJicrpeq3kuU1VA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
