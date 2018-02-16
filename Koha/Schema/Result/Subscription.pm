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
  default_value: 0
  is_nullable: 0

=head2 subscriptionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 librarian

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 100

=head2 startdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 aqbooksellerid

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

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

=head2 monthlength

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 numberlength

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 periodicity

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 countissuesperunit

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

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

=head2 manualhistory

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 irregularity

  data_type: 'mediumtext'
  is_nullable: 1

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

=head2 locale

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 distributedto

  data_type: 'mediumtext'
  is_nullable: 1

=head2 internalnotes

  data_type: 'longtext'
  is_nullable: 1

=head2 callnumber

  data_type: 'mediumtext'
  is_nullable: 1

=head2 location

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 80

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 lastbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 serialsadditems

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 staffdisplaycount

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 opacdisplaycount

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 graceperiod

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 enddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 closed

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 reneweddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 previousitemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
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
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "opacdisplaycount",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "graceperiod",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "enddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "closed",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "reneweddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "previousitemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZRLfM/4h8VMLTgW7LkUYYA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
