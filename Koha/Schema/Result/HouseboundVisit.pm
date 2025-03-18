use utf8;
package Koha::Schema::Result::HouseboundVisit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::HouseboundVisit

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<housebound_visit>

=cut

__PACKAGE__->table("housebound_visit");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

ID of the visit.

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Number of the borrower, & the profile, linked to this visit.

=head2 appointment_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Date of visit.

=head2 day_segment

  data_type: 'varchar'
  is_nullable: 1
  size: 10

Rough time frame: 'morning', 'afternoon' 'evening'

=head2 chooser_brwnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

Number of the borrower to choose items  for delivery.

=head2 deliverer_brwnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

Number of the borrower to deliver items.

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "appointment_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "day_segment",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "chooser_brwnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "deliverer_brwnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::HouseboundProfile>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::HouseboundProfile",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 chooser_brwnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "chooser_brwnumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "chooser_brwnumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 deliverer_brwnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "deliverer_brwnumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "deliverer_brwnumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PJwWk4901BF+CG6AXgjffg

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::HouseboundVisit';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::HouseboundVisits';
}

1;
