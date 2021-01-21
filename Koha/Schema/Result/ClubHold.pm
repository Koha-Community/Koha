use utf8;
package Koha::Schema::Result::ClubHold;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClubHold

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<club_holds>

=cut

__PACKAGE__->table("club_holds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 club_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

id for the club the hold was generated for

=head2 biblio_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

id for the bibliographic record the hold has been placed against

=head2 item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

If item-level, the id for the item the hold has been placed agains

=head2 date_created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Timestamp for the placed hold

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "club_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "biblio_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "date_created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 club

Type: belongs_to

Related object: L<Koha::Schema::Result::Club>

=cut

__PACKAGE__->belongs_to(
  "club",
  "Koha::Schema::Result::Club",
  { id => "club_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 club_holds_to_patron_holds

Type: has_many

Related object: L<Koha::Schema::Result::ClubHoldsToPatronHold>

=cut

__PACKAGE__->has_many(
  "club_holds_to_patron_holds",
  "Koha::Schema::Result::ClubHoldsToPatronHold",
  { "foreign.club_hold_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dGkIYbw9CX0LqiH8XmuGAQ

sub koha_objects_class {
    'Koha::Club::Holds';
}
sub koha_object_class {
    'Koha::Club::Hold';
}
1;
