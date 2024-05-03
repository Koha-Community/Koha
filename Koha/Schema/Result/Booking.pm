use utf8;
package Koha::Schema::Result::Booking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Booking

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<bookings>

=cut

__PACKAGE__->table("bookings");

=head1 ACCESSORS

=head2 booking_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 patron_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

foreign key from the borrowers table defining which patron this booking is for

=head2 biblio_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

foreign key from the biblio table defining which bib record this booking is on

=head2 item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the items table defining the specific item the patron has placed a booking for

=head2 pickup_library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

Identifier for booking pickup library

=head2 start_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the start date of the booking

=head2 end_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the end date of the booking

=cut

__PACKAGE__->add_columns(
  "booking_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patron_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "biblio_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "pickup_library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "start_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "end_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</booking_id>

=back

=cut

__PACKAGE__->set_primary_key("booking_id");

=head1 RELATIONS

=head2 biblio

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblio",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblio_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 item

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "item_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 patron

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "patron",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "patron_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 pickup_library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "pickup_library",
  "Koha::Schema::Result::Branch",
  { branchcode => "pickup_library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-05-03 13:13:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pgq1xPy2zo3pdkJb801djA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
