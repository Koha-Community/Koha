package Koha::Schema::Result::Borrower;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Borrower

=cut

__PACKAGE__->table("borrowers");

=head1 ACCESSORS

=head2 borrowernumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 cardnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 surname

  data_type: 'mediumtext'
  is_nullable: 0

=head2 firstname

  data_type: 'text'
  is_nullable: 1

=head2 title

  data_type: 'mediumtext'
  is_nullable: 1

=head2 othernames

  data_type: 'mediumtext'
  is_nullable: 1

=head2 initials

  data_type: 'text'
  is_nullable: 1

=head2 streetnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 streettype

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 address

  data_type: 'mediumtext'
  is_nullable: 0

=head2 address2

  data_type: 'text'
  is_nullable: 1

=head2 city

  data_type: 'mediumtext'
  is_nullable: 0

=head2 state

  data_type: 'mediumtext'
  is_nullable: 1

=head2 zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 country

  data_type: 'text'
  is_nullable: 1

=head2 email

  data_type: 'mediumtext'
  is_nullable: 1

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 mobile

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 fax

  data_type: 'mediumtext'
  is_nullable: 1

=head2 emailpro

  data_type: 'text'
  is_nullable: 1

=head2 phonepro

  data_type: 'text'
  is_nullable: 1

=head2 b_streetnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 b_streettype

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 b_address

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 b_address2

  data_type: 'text'
  is_nullable: 1

=head2 b_city

  data_type: 'mediumtext'
  is_nullable: 1

=head2 b_state

  data_type: 'mediumtext'
  is_nullable: 1

=head2 b_zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 b_country

  data_type: 'text'
  is_nullable: 1

=head2 b_email

  data_type: 'text'
  is_nullable: 1

=head2 b_phone

  data_type: 'mediumtext'
  is_nullable: 1

=head2 dateofbirth

  data_type: 'date'
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 dateenrolled

  data_type: 'date'
  is_nullable: 1

=head2 dateexpiry

  data_type: 'date'
  is_nullable: 1

=head2 gonenoaddress

  data_type: 'tinyint'
  is_nullable: 1

=head2 lost

  data_type: 'tinyint'
  is_nullable: 1

=head2 debarred

  data_type: 'date'
  is_nullable: 1

=head2 debarredcomment

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 contactname

  data_type: 'mediumtext'
  is_nullable: 1

=head2 contactfirstname

  data_type: 'text'
  is_nullable: 1

=head2 contacttitle

  data_type: 'text'
  is_nullable: 1

=head2 guarantorid

  data_type: 'integer'
  is_nullable: 1

=head2 borrowernotes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 relationship

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 ethnicity

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 ethnotes

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 sex

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 flags

  data_type: 'integer'
  is_nullable: 1

=head2 userid

  data_type: 'varchar'
  is_nullable: 1
  size: 75

=head2 opacnote

  data_type: 'mediumtext'
  is_nullable: 1

=head2 contactnote

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 sort1

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 sort2

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 altcontactfirstname

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 altcontactsurname

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 altcontactaddress1

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 altcontactaddress2

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 altcontactaddress3

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 altcontactstate

  data_type: 'mediumtext'
  is_nullable: 1

=head2 altcontactzipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 altcontactcountry

  data_type: 'text'
  is_nullable: 1

=head2 altcontactphone

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 smsalertnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 privacy

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "borrowernumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "cardnumber",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "surname",
  { data_type => "mediumtext", is_nullable => 0 },
  "firstname",
  { data_type => "text", is_nullable => 1 },
  "title",
  { data_type => "mediumtext", is_nullable => 1 },
  "othernames",
  { data_type => "mediumtext", is_nullable => 1 },
  "initials",
  { data_type => "text", is_nullable => 1 },
  "streetnumber",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "streettype",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "address",
  { data_type => "mediumtext", is_nullable => 0 },
  "address2",
  { data_type => "text", is_nullable => 1 },
  "city",
  { data_type => "mediumtext", is_nullable => 0 },
  "state",
  { data_type => "mediumtext", is_nullable => 1 },
  "zipcode",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "country",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "mediumtext", is_nullable => 1 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "mobile",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "fax",
  { data_type => "mediumtext", is_nullable => 1 },
  "emailpro",
  { data_type => "text", is_nullable => 1 },
  "phonepro",
  { data_type => "text", is_nullable => 1 },
  "b_streetnumber",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "b_streettype",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "b_address",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "b_address2",
  { data_type => "text", is_nullable => 1 },
  "b_city",
  { data_type => "mediumtext", is_nullable => 1 },
  "b_state",
  { data_type => "mediumtext", is_nullable => 1 },
  "b_zipcode",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "b_country",
  { data_type => "text", is_nullable => 1 },
  "b_email",
  { data_type => "text", is_nullable => 1 },
  "b_phone",
  { data_type => "mediumtext", is_nullable => 1 },
  "dateofbirth",
  { data_type => "date", is_nullable => 1 },
  "branchcode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "categorycode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "dateenrolled",
  { data_type => "date", is_nullable => 1 },
  "dateexpiry",
  { data_type => "date", is_nullable => 1 },
  "gonenoaddress",
  { data_type => "tinyint", is_nullable => 1 },
  "lost",
  { data_type => "tinyint", is_nullable => 1 },
  "debarred",
  { data_type => "date", is_nullable => 1 },
  "debarredcomment",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "contactname",
  { data_type => "mediumtext", is_nullable => 1 },
  "contactfirstname",
  { data_type => "text", is_nullable => 1 },
  "contacttitle",
  { data_type => "text", is_nullable => 1 },
  "guarantorid",
  { data_type => "integer", is_nullable => 1 },
  "borrowernotes",
  { data_type => "mediumtext", is_nullable => 1 },
  "relationship",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "ethnicity",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "ethnotes",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sex",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "flags",
  { data_type => "integer", is_nullable => 1 },
  "userid",
  { data_type => "varchar", is_nullable => 1, size => 75 },
  "opacnote",
  { data_type => "mediumtext", is_nullable => 1 },
  "contactnote",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sort1",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "sort2",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "altcontactfirstname",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "altcontactsurname",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "altcontactaddress1",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "altcontactaddress2",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "altcontactaddress3",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "altcontactstate",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactzipcode",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "altcontactcountry",
  { data_type => "text", is_nullable => 1 },
  "altcontactphone",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "smsalertnumber",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "privacy",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("borrowernumber");
__PACKAGE__->add_unique_constraint("cardnumber", ["cardnumber"]);

=head1 RELATIONS

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 accountoffsets

Type: has_many

Related object: L<Koha::Schema::Result::Accountoffset>

=cut

__PACKAGE__->has_many(
  "accountoffsets",
  "Koha::Schema::Result::Accountoffset",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqbudgetborrowers

Type: has_many

Related object: L<Koha::Schema::Result::Aqbudgetborrower>

=cut

__PACKAGE__->has_many(
  "aqbudgetborrowers",
  "Koha::Schema::Result::Aqbudgetborrower",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_attributes

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerAttribute>

=cut

__PACKAGE__->has_many(
  "borrower_attributes",
  "Koha::Schema::Result::BorrowerAttribute",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_files

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerFile>

=cut

__PACKAGE__->has_many(
  "borrower_files",
  "Koha::Schema::Result::BorrowerFile",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_message_preferences

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerMessagePreference>

=cut

__PACKAGE__->has_many(
  "borrower_message_preferences",
  "Koha::Schema::Result::BorrowerMessagePreference",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 categorycode

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "categorycode",
  "Koha::Schema::Result::Category",
  { categorycode => "categorycode" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 creator_batches

Type: has_many

Related object: L<Koha::Schema::Result::CreatorBatch>

=cut

__PACKAGE__->has_many(
  "creator_batches",
  "Koha::Schema::Result::CreatorBatch",
  { "foreign.borrower_number" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hold_fill_targets

Type: has_many

Related object: L<Koha::Schema::Result::HoldFillTarget>

=cut

__PACKAGE__->has_many(
  "hold_fill_targets",
  "Koha::Schema::Result::HoldFillTarget",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 issues

Type: has_many

Related object: L<Koha::Schema::Result::Issue>

=cut

__PACKAGE__->has_many(
  "issues",
  "Koha::Schema::Result::Issue",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 message_queues

Type: has_many

Related object: L<Koha::Schema::Result::MessageQueue>

=cut

__PACKAGE__->has_many(
  "message_queues",
  "Koha::Schema::Result::MessageQueue",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_issues

Type: has_many

Related object: L<Koha::Schema::Result::OldIssue>

=cut

__PACKAGE__->has_many(
  "old_issues",
  "Koha::Schema::Result::OldIssue",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 patroncards

Type: has_many

Related object: L<Koha::Schema::Result::Patroncard>

=cut

__PACKAGE__->has_many(
  "patroncards",
  "Koha::Schema::Result::Patroncard",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 patronimage

Type: might_have

Related object: L<Koha::Schema::Result::Patronimage>

=cut

__PACKAGE__->might_have(
  "patronimage",
  "Koha::Schema::Result::Patronimage",
  { "foreign.cardnumber" => "self.cardnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ratings

Type: has_many

Related object: L<Koha::Schema::Result::Rating>

=cut

__PACKAGE__->has_many(
  "ratings",
  "Koha::Schema::Result::Rating",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reviews

Type: has_many

Related object: L<Koha::Schema::Result::Review>

=cut

__PACKAGE__->has_many(
  "reviews",
  "Koha::Schema::Result::Review",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subscriptionroutinglists

Type: has_many

Related object: L<Koha::Schema::Result::Subscriptionroutinglist>

=cut

__PACKAGE__->has_many(
  "subscriptionroutinglists",
  "Koha::Schema::Result::Subscriptionroutinglist",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags_all

Type: has_many

Related object: L<Koha::Schema::Result::TagAll>

=cut

__PACKAGE__->has_many(
  "tags_all",
  "Koha::Schema::Result::TagAll",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags_approvals

Type: has_many

Related object: L<Koha::Schema::Result::TagsApproval>

=cut

__PACKAGE__->has_many(
  "tags_approvals",
  "Koha::Schema::Result::TagsApproval",
  { "foreign.approved_by" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_permissions

Type: has_many

Related object: L<Koha::Schema::Result::UserPermission>

=cut

__PACKAGE__->has_many(
  "user_permissions",
  "Koha::Schema::Result::UserPermission",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 virtualshelfcontents

Type: has_many

Related object: L<Koha::Schema::Result::Virtualshelfcontent>

=cut

__PACKAGE__->has_many(
  "virtualshelfcontents",
  "Koha::Schema::Result::Virtualshelfcontent",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 virtualshelfshares

Type: has_many

Related object: L<Koha::Schema::Result::Virtualshelfshare>

=cut

__PACKAGE__->has_many(
  "virtualshelfshares",
  "Koha::Schema::Result::Virtualshelfshare",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 virtualshelves

Type: has_many

Related object: L<Koha::Schema::Result::Virtualshelve>

=cut

__PACKAGE__->has_many(
  "virtualshelves",
  "Koha::Schema::Result::Virtualshelve",
  { "foreign.owner" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a5PYhuHX3DHlNJqdmIuqTw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
