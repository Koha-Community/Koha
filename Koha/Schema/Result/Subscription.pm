use utf8;
package Koha::Schema::Result::Subscription;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Subscription

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<subscription>

=cut

__PACKAGE__->table("subscription");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key for biblio.biblionumber that this subscription is attached to

=head2 subscriptionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique key for this subscription

=head2 librarian

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 100

the librarian's username from borrowers.userid

=head2 startdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

start date for this subscription

=head2 aqbooksellerid

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

foreign key for aqbooksellers.id to link to the vendor

=head2 cost

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 aqbudgetid

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 weeklength

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

subscription length in weeks (will not be filled in if monthlength or numberlength is set)

=head2 monthlength

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

subscription length in weeks (will not be filled in if weeklength or numberlength is set)

=head2 numberlength

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

subscription length in weeks (will not be filled in if monthlength or weeklength is set)

=head2 periodicity

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

frequency type links to subscription_frequencies.id

=head2 countissuesperunit

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

notes

=head2 status

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

status of this subscription

=head2 lastvalue1

  data_type: 'integer'
  is_nullable: 1

=head2 innerloop1

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 lastvalue2

  data_type: 'integer'
  is_nullable: 1

=head2 innerloop2

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 lastvalue3

  data_type: 'integer'
  is_nullable: 1

=head2 innerloop3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 firstacquidate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

first issue received date

=head2 manualhistory

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

yes or no to managing the history manually

=head2 irregularity

  data_type: 'mediumtext'
  is_nullable: 1

any irregularities in the subscription

=head2 skip_serialseq

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 letter

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 numberpattern

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

the numbering pattern used links to subscription_numberpatterns.id

=head2 locale

  data_type: 'varchar'
  is_nullable: 1
  size: 80

for foreign language subscriptions to display months, seasons, etc correctly

=head2 distributedto

  data_type: 'mediumtext'
  is_nullable: 1

=head2 internalnotes

  data_type: 'longtext'
  is_nullable: 1

=head2 callnumber

  data_type: 'mediumtext'
  is_nullable: 1

default call number

=head2 location

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 80

default shelving location (items.location)

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

default branches (items.homebranch)

=head2 lastbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 serialsadditems

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

does receiving this serial create an item record

=head2 staffdisplaycount

  data_type: 'integer'
  is_nullable: 1

how many issues to show to the staff

=head2 opacdisplaycount

  data_type: 'integer'
  is_nullable: 1

how many issues to show to the public

=head2 graceperiod

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

grace period in days

=head2 enddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

subscription end date

=head2 closed

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

yes / no if the subscription is closed

=head2 reneweddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date of last renewal for the subscription

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 previousitemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 mana_id

  data_type: 'integer'
  is_nullable: 1

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

collection code to assign to serial items

=head2 published_on_template

  data_type: 'text'
  is_nullable: 1

Template Toolkit syntax to generate the default "Published on (text)" field when receiving an issue this serial

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "subscriptionid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "librarian",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 100 },
  "startdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "aqbooksellerid",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "cost",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "aqbudgetid",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "weeklength",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "monthlength",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "numberlength",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "periodicity",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "countissuesperunit",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
  "status",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "lastvalue1",
  { data_type => "integer", is_nullable => 1 },
  "innerloop1",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "lastvalue2",
  { data_type => "integer", is_nullable => 1 },
  "innerloop2",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "lastvalue3",
  { data_type => "integer", is_nullable => 1 },
  "innerloop3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "firstacquidate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "manualhistory",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "irregularity",
  { data_type => "mediumtext", is_nullable => 1 },
  "skip_serialseq",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "letter",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "numberpattern",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "locale",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "distributedto",
  { data_type => "mediumtext", is_nullable => 1 },
  "internalnotes",
  { data_type => "longtext", is_nullable => 1 },
  "callnumber",
  { data_type => "mediumtext", is_nullable => 1 },
  "location",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 80 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "lastbranch",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "serialsadditems",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "staffdisplaycount",
  { data_type => "integer", is_nullable => 1 },
  "opacdisplaycount",
  { data_type => "integer", is_nullable => 1 },
  "graceperiod",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "enddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "closed",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "reneweddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "previousitemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "mana_id",
  { data_type => "integer", is_nullable => 1 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "published_on_template",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</subscriptionid>

=back

=cut

__PACKAGE__->set_primary_key("subscriptionid");

=head1 RELATIONS

=head2 aqorders

Type: has_many

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->has_many(
  "aqorders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.subscriptionid" => "self.subscriptionid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 numberpattern

Type: belongs_to

Related object: L<Koha::Schema::Result::SubscriptionNumberpattern>

=cut

__PACKAGE__->belongs_to(
  "numberpattern",
  "Koha::Schema::Result::SubscriptionNumberpattern",
  { id => "numberpattern" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 periodicity

Type: belongs_to

Related object: L<Koha::Schema::Result::SubscriptionFrequency>

=cut

__PACKAGE__->belongs_to(
  "periodicity",
  "Koha::Schema::Result::SubscriptionFrequency",
  { id => "periodicity" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 serials

Type: has_many

Related object: L<Koha::Schema::Result::Serial>

=cut

__PACKAGE__->has_many(
  "serials",
  "Koha::Schema::Result::Serial",
  { "foreign.subscriptionid" => "self.subscriptionid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subscriptionhistory

Type: might_have

Related object: L<Koha::Schema::Result::Subscriptionhistory>

=cut

__PACKAGE__->might_have(
  "subscriptionhistory",
  "Koha::Schema::Result::Subscriptionhistory",
  { "foreign.subscriptionid" => "self.subscriptionid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subscriptionroutinglists

Type: has_many

Related object: L<Koha::Schema::Result::Subscriptionroutinglist>

=cut

__PACKAGE__->has_many(
  "subscriptionroutinglists",
  "Koha::Schema::Result::Subscriptionroutinglist",
  { "foreign.subscriptionid" => "self.subscriptionid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-07-14 11:46:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LICIiWzag365cUAq5OYD2A

__PACKAGE__->has_many(
  "additional_field_values",
  "Koha::Schema::Result::AdditionalFieldValue",
  sub {
    my ($args) = @_;

    return {
        "$args->{foreign_alias}.record_id" => { -ident => "$args->{self_alias}.subscriptionid" },

        "$args->{foreign_alias}.field_id" =>
            { -in => \'(SELECT id FROM additional_fields WHERE tablename = "subscription")' },
    };
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    '+closed'         => { is_boolean => 1 },
    '+skip_serialseq' => { is_boolean => 1 },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
