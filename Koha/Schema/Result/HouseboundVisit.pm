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

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 appointment_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 day_segment

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 chooser_brwnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 deliverer_brwnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-04-25 13:21:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5zyc7l2BtF5cgpZeKbJNZg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
