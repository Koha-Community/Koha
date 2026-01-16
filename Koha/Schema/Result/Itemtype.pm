use utf8;
package Koha::Schema::Result::Itemtype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Itemtype

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<itemtypes>

=cut

__PACKAGE__->table("itemtypes");

=head1 ACCESSORS

=head2 itemtype

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

unique key, a code associated with the item type

=head2 parent_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

unique key, a code associated with the item type

=head2 description

  data_type: 'longtext'
  is_nullable: 1

a plain text explanation of the item type

=head2 rentalcharge

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

the amount charged when this item is checked out/issued

=head2 rentalcharge_daily

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

the amount charged for each day between checkout date and due date

=head2 rentalcharge_daily_calendar

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

controls if the daily rental fee is calculated directly or using finesCalendar

=head2 rentalcharge_hourly

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

the amount charged for each hour between checkout date and due date

=head2 rentalcharge_hourly_calendar

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

controls if the hourly rental fee is calculated directly or using finesCalendar

=head2 defaultreplacecost

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

default replacement cost

=head2 notforloan

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

1 if the item is not for loan, 0 if the item is available for loan

=head2 imageurl

  data_type: 'varchar'
  is_nullable: 1
  size: 200

URL for the item type icon

=head2 summary

  data_type: 'mediumtext'
  is_nullable: 1

information from the summary field, may include HTML

=head2 checkinmsg

  data_type: 'varchar'
  is_nullable: 1
  size: 255

message that is displayed when an item with the given item type is checked in

=head2 checkinmsgtype

  data_type: 'char'
  default_value: 'message'
  is_nullable: 0
  size: 16

type (CSS class) for the checkinmsg, can be 'alert' or 'message'

=head2 sip_media_type

  data_type: 'varchar'
  is_nullable: 1
  size: 3

SIP2 protocol media type for this itemtype

=head2 sip_magnetic

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Indicates if items of this type are magnetic media for SIP

=head2 hideinopac

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Hide the item type from the search options in OPAC

=head2 searchcategory

  data_type: 'varchar'
  is_nullable: 1
  size: 80

Group this item type with others with the same value on OPAC search options

=head2 automatic_checkin

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

If automatic checkin is enabled for items of this type

=head2 bookable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Activate bookable feature for items related to this item type

=head2 checkprevcheckout

  data_type: 'enum'
  default_value: 'inherit'
  extra: {list => ["yes","no","inherit"]}
  is_nullable: 0

produce a warning for a patron if a item of this type has previously been checked out to the same patron if 'yes', not if 'no', defer to category setting if 'inherit'.

=cut

__PACKAGE__->add_columns(
  "itemtype",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "parent_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "rentalcharge",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "rentalcharge_daily",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "rentalcharge_daily_calendar",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "rentalcharge_hourly",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "rentalcharge_hourly_calendar",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "defaultreplacecost",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "notforloan",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "imageurl",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "summary",
  { data_type => "mediumtext", is_nullable => 1 },
  "checkinmsg",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "checkinmsgtype",
  {
    data_type => "char",
    default_value => "message",
    is_nullable => 0,
    size => 16,
  },
  "sip_media_type",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "sip_magnetic",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "hideinopac",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "searchcategory",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "automatic_checkin",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "bookable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "checkprevcheckout",
  {
    data_type => "enum",
    default_value => "inherit",
    extra => { list => ["yes", "no", "inherit"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</itemtype>

=back

=cut

__PACKAGE__->set_primary_key("itemtype");

=head1 RELATIONS

=head2 circulation_rules

Type: has_many

Related object: L<Koha::Schema::Result::CirculationRule>

=cut

__PACKAGE__->has_many(
  "circulation_rules",
  "Koha::Schema::Result::CirculationRule",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 itemtypes

Type: has_many

Related object: L<Koha::Schema::Result::Itemtype>

=cut

__PACKAGE__->has_many(
  "itemtypes",
  "Koha::Schema::Result::Itemtype",
  { "foreign.parent_type" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 itemtypes_branches

Type: has_many

Related object: L<Koha::Schema::Result::ItemtypesBranch>

=cut

__PACKAGE__->has_many(
  "itemtypes_branches",
  "Koha::Schema::Result::ItemtypesBranch",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 library_float_limits

Type: has_many

Related object: L<Koha::Schema::Result::LibraryFloatLimit>

=cut

__PACKAGE__->has_many(
  "library_float_limits",
  "Koha::Schema::Result::LibraryFloatLimit",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent_type

Type: belongs_to

Related object: L<Koha::Schema::Result::Itemtype>

=cut

__PACKAGE__->belongs_to(
  "parent_type",
  "Koha::Schema::Result::Itemtype",
  { itemtype => "parent_type" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2026-02-27 18:28:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nIbK4y9VAP6U+o7feeGsDA

__PACKAGE__->add_columns(
    '+automatic_checkin'            => { is_boolean => 1 },
    '+hideinopac'                   => { is_boolean => 1 },
    '+notforloan'                   => { is_boolean => 1 },
    '+rentalcharge_daily_calendar'  => { is_boolean => 1 },
    '+rentalcharge_hourly_calendar' => { is_boolean => 1 },
    '+bookable'                     => { is_boolean => 1, is_nullable => 1 },
);

__PACKAGE__->load_components('+Koha::Schema::Component::Localization');
__PACKAGE__->localization_add_relationships('itemtype', 'description');

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ItemType';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ItemTypes';
}

1;
