package Koha::Schema::Result::Subscription;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Subscription

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

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 dow

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 100

=head2 numberingmethod

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 100

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 add1

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 every1

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 whenmorethan1

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 setto1

  data_type: 'integer'
  is_nullable: 1

=head2 lastvalue1

  data_type: 'integer'
  is_nullable: 1

=head2 add2

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 every2

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 whenmorethan2

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 setto2

  data_type: 'integer'
  is_nullable: 1

=head2 lastvalue2

  data_type: 'integer'
  is_nullable: 1

=head2 add3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 every3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 innerloop1

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 innerloop2

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 innerloop3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 whenmorethan3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 setto3

  data_type: 'integer'
  is_nullable: 1

=head2 lastvalue3

  data_type: 'integer'
  is_nullable: 1

=head2 issuesatonce

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 firstacquidate

  data_type: 'date'
  is_nullable: 1

=head2 manualhistory

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 irregularity

  data_type: 'text'
  is_nullable: 1

=head2 letter

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 numberpattern

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 distributedto

  data_type: 'text'
  is_nullable: 1

=head2 internalnotes

  data_type: 'longtext'
  is_nullable: 1

=head2 callnumber

  data_type: 'text'
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

=head2 hemisphere

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

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
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "subscriptionid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "librarian",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 100 },
  "startdate",
  { data_type => "date", is_nullable => 1 },
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
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "dow",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 100 },
  "numberingmethod",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 100 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "status",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "add1",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "every1",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "whenmorethan1",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "setto1",
  { data_type => "integer", is_nullable => 1 },
  "lastvalue1",
  { data_type => "integer", is_nullable => 1 },
  "add2",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "every2",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "whenmorethan2",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "setto2",
  { data_type => "integer", is_nullable => 1 },
  "lastvalue2",
  { data_type => "integer", is_nullable => 1 },
  "add3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "every3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "innerloop1",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "innerloop2",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "innerloop3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "whenmorethan3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "setto3",
  { data_type => "integer", is_nullable => 1 },
  "lastvalue3",
  { data_type => "integer", is_nullable => 1 },
  "issuesatonce",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "firstacquidate",
  { data_type => "date", is_nullable => 1 },
  "manualhistory",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "irregularity",
  { data_type => "text", is_nullable => 1 },
  "letter",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "numberpattern",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "distributedto",
  { data_type => "text", is_nullable => 1 },
  "internalnotes",
  { data_type => "longtext", is_nullable => 1 },
  "callnumber",
  { data_type => "text", is_nullable => 1 },
  "location",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 80 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "hemisphere",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
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
  { data_type => "date", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("subscriptionid");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V94nwW1uwvdVX634/QPe6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
