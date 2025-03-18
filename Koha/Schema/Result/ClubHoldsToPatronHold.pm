use utf8;
package Koha::Schema::Result::ClubHoldsToPatronHold;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClubHoldsToPatronHold

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<club_holds_to_patron_holds>

=cut

__PACKAGE__->table("club_holds_to_patron_holds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 club_hold_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 patron_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 hold_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 error_code

  data_type: 'enum'
  extra: {list => ["damaged","ageRestricted","itemAlreadyOnHold","tooManyHoldsForThisRecord","tooManyReservesToday","tooManyReserves","notReservable","cannotReserveFromOtherBranches","libraryNotFound","libraryNotPickupLocation","cannotBeTransferred","noReservesAllowed"]}
  is_nullable: 1

=head2 error_message

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "club_hold_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "patron_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "hold_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "error_code",
  {
    data_type => "enum",
    extra => {
      list => [
        "damaged",
        "ageRestricted",
        "itemAlreadyOnHold",
        "tooManyHoldsForThisRecord",
        "tooManyReservesToday",
        "tooManyReserves",
        "notReservable",
        "cannotReserveFromOtherBranches",
        "libraryNotFound",
        "libraryNotPickupLocation",
        "cannotBeTransferred",
        "noReservesAllowed",
      ],
    },
    is_nullable => 1,
  },
  "error_message",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 club_hold

Type: belongs_to

Related object: L<Koha::Schema::Result::ClubHold>

=cut

__PACKAGE__->belongs_to(
  "club_hold",
  "Koha::Schema::Result::ClubHold",
  { id => "club_hold_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 hold

Type: belongs_to

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->belongs_to(
  "hold",
  "Koha::Schema::Result::Reserve",
  { reserve_id => "hold_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2020-08-04 18:43:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KjJWzFhPwQk0SZqrHQ4Alw

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Club::Hold::PatronHolds';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Club::Hold::PatronHold';
}

1;
