use utf8;
package Koha::Schema::Result::Borrower;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Borrower

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrowers>

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
  size: 32

=head2 surname

  data_type: 'longtext'
  is_nullable: 1

=head2 firstname

  data_type: 'mediumtext'
  is_nullable: 1

=head2 title

  data_type: 'longtext'
  is_nullable: 1

=head2 othernames

  data_type: 'longtext'
  is_nullable: 1

=head2 initials

  data_type: 'mediumtext'
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

  data_type: 'longtext'
  is_nullable: 1

=head2 address2

  data_type: 'mediumtext'
  is_nullable: 1

=head2 city

  data_type: 'longtext'
  is_nullable: 1

=head2 state

  data_type: 'mediumtext'
  is_nullable: 1

=head2 zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 country

  data_type: 'mediumtext'
  is_nullable: 1

=head2 email

  data_type: 'longtext'
  is_nullable: 1

=head2 phone

  data_type: 'mediumtext'
  is_nullable: 1

=head2 mobile

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 fax

  data_type: 'longtext'
  is_nullable: 1

=head2 emailpro

  data_type: 'mediumtext'
  is_nullable: 1

=head2 phonepro

  data_type: 'mediumtext'
  is_nullable: 1

=head2 B_streetnumber

  accessor: 'b_streetnumber'
  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 B_streettype

  accessor: 'b_streettype'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 B_address

  accessor: 'b_address'
  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 B_address2

  accessor: 'b_address2'
  data_type: 'mediumtext'
  is_nullable: 1

=head2 B_city

  accessor: 'b_city'
  data_type: 'longtext'
  is_nullable: 1

=head2 B_state

  accessor: 'b_state'
  data_type: 'mediumtext'
  is_nullable: 1

=head2 B_zipcode

  accessor: 'b_zipcode'
  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 B_country

  accessor: 'b_country'
  data_type: 'mediumtext'
  is_nullable: 1

=head2 B_email

  accessor: 'b_email'
  data_type: 'mediumtext'
  is_nullable: 1

=head2 B_phone

  accessor: 'b_phone'
  data_type: 'longtext'
  is_nullable: 1

=head2 dateofbirth

  data_type: 'date'
  datetime_undef_if_invalid: 1
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
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 dateexpiry

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 date_renewed

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 gonenoaddress

  data_type: 'tinyint'
  is_nullable: 1

=head2 lost

  data_type: 'tinyint'
  is_nullable: 1

=head2 debarred

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 debarredcomment

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 contactname

  data_type: 'longtext'
  is_nullable: 1

=head2 contactfirstname

  data_type: 'mediumtext'
  is_nullable: 1

=head2 contacttitle

  data_type: 'mediumtext'
  is_nullable: 1

=head2 guarantorid

  data_type: 'integer'
  is_nullable: 1

=head2 borrowernotes

  data_type: 'longtext'
  is_nullable: 1

=head2 relationship

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 sex

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 flags

  data_type: 'integer'
  is_nullable: 1

=head2 userid

  data_type: 'varchar'
  is_nullable: 1
  size: 75

=head2 opacnote

  data_type: 'longtext'
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

  data_type: 'mediumtext'
  is_nullable: 1

=head2 altcontactphone

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 smsalertnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 sms_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 privacy

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 privacy_guarantor_checkouts

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 checkprevcheckout

  data_type: 'varchar'
  default_value: 'inherit'
  is_nullable: 0
  size: 7

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 lastseen

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 lang

  data_type: 'varchar'
  default_value: 'default'
  is_nullable: 0
  size: 25

=head2 login_attempts

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 overdrive_auth_token

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "borrowernumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "cardnumber",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "surname",
  { data_type => "longtext", is_nullable => 1 },
  "firstname",
  { data_type => "mediumtext", is_nullable => 1 },
  "title",
  { data_type => "longtext", is_nullable => 1 },
  "othernames",
  { data_type => "longtext", is_nullable => 1 },
  "initials",
  { data_type => "mediumtext", is_nullable => 1 },
  "streetnumber",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "streettype",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "address",
  { data_type => "longtext", is_nullable => 1 },
  "address2",
  { data_type => "mediumtext", is_nullable => 1 },
  "city",
  { data_type => "longtext", is_nullable => 1 },
  "state",
  { data_type => "mediumtext", is_nullable => 1 },
  "zipcode",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "country",
  { data_type => "mediumtext", is_nullable => 1 },
  "email",
  { data_type => "longtext", is_nullable => 1 },
  "phone",
  { data_type => "mediumtext", is_nullable => 1 },
  "mobile",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "fax",
  { data_type => "longtext", is_nullable => 1 },
  "emailpro",
  { data_type => "mediumtext", is_nullable => 1 },
  "phonepro",
  { data_type => "mediumtext", is_nullable => 1 },
  "B_streetnumber",
  {
    accessor => "b_streetnumber",
    data_type => "varchar",
    is_nullable => 1,
    size => 10,
  },
  "B_streettype",
  {
    accessor => "b_streettype",
    data_type => "varchar",
    is_nullable => 1,
    size => 50,
  },
  "B_address",
  {
    accessor => "b_address",
    data_type => "varchar",
    is_nullable => 1,
    size => 100,
  },
  "B_address2",
  { accessor => "b_address2", data_type => "mediumtext", is_nullable => 1 },
  "B_city",
  { accessor => "b_city", data_type => "longtext", is_nullable => 1 },
  "B_state",
  { accessor => "b_state", data_type => "mediumtext", is_nullable => 1 },
  "B_zipcode",
  {
    accessor => "b_zipcode",
    data_type => "varchar",
    is_nullable => 1,
    size => 25,
  },
  "B_country",
  { accessor => "b_country", data_type => "mediumtext", is_nullable => 1 },
  "B_email",
  { accessor => "b_email", data_type => "mediumtext", is_nullable => 1 },
  "B_phone",
  { accessor => "b_phone", data_type => "longtext", is_nullable => 1 },
  "dateofbirth",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
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
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "dateexpiry",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "date_renewed",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "gonenoaddress",
  { data_type => "tinyint", is_nullable => 1 },
  "lost",
  { data_type => "tinyint", is_nullable => 1 },
  "debarred",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "debarredcomment",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "contactname",
  { data_type => "longtext", is_nullable => 1 },
  "contactfirstname",
  { data_type => "mediumtext", is_nullable => 1 },
  "contacttitle",
  { data_type => "mediumtext", is_nullable => 1 },
  "guarantorid",
  { data_type => "integer", is_nullable => 1 },
  "borrowernotes",
  { data_type => "longtext", is_nullable => 1 },
  "relationship",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "sex",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "flags",
  { data_type => "integer", is_nullable => 1 },
  "userid",
  { data_type => "varchar", is_nullable => 1, size => 75 },
  "opacnote",
  { data_type => "longtext", is_nullable => 1 },
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
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactphone",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "smsalertnumber",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "sms_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "privacy",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "privacy_guarantor_checkouts",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "checkprevcheckout",
  {
    data_type => "varchar",
    default_value => "inherit",
    is_nullable => 0,
    size => 7,
  },
  "updated_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "lastseen",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "lang",
  {
    data_type => "varchar",
    default_value => "default",
    is_nullable => 0,
    size => 25,
  },
  "login_attempts",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "overdrive_auth_token",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrowernumber>

=back

=cut

__PACKAGE__->set_primary_key("borrowernumber");

=head1 UNIQUE CONSTRAINTS

=head2 C<cardnumber>

=over 4

=item * L</cardnumber>

=back

=cut

__PACKAGE__->add_unique_constraint("cardnumber", ["cardnumber"]);

=head2 C<userid>

=over 4

=item * L</userid>

=back

=cut

__PACKAGE__->add_unique_constraint("userid", ["userid"]);

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

=head2 api_keys

Type: has_many

Related object: L<Koha::Schema::Result::ApiKey>

=cut

__PACKAGE__->has_many(
  "api_keys",
  "Koha::Schema::Result::ApiKey",
  { "foreign.patron_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqbasketusers

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasketuser>

=cut

__PACKAGE__->has_many(
  "aqbasketusers",
  "Koha::Schema::Result::Aqbasketuser",
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

=head2 aqorder_users

Type: has_many

Related object: L<Koha::Schema::Result::AqorderUser>

=cut

__PACKAGE__->has_many(
  "aqorder_users",
  "Koha::Schema::Result::AqorderUser",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqorders

Type: has_many

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->has_many(
  "aqorders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.created_by" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 article_requests

Type: has_many

Related object: L<Koha::Schema::Result::ArticleRequest>

=cut

__PACKAGE__->has_many(
  "article_requests",
  "Koha::Schema::Result::ArticleRequest",
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

=head2 borrower_debarments

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerDebarment>

=cut

__PACKAGE__->has_many(
  "borrower_debarments",
  "Koha::Schema::Result::BorrowerDebarment",
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

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 categorycode

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "categorycode",
  "Koha::Schema::Result::Category",
  { categorycode => "categorycode" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 club_enrollments

Type: has_many

Related object: L<Koha::Schema::Result::ClubEnrollment>

=cut

__PACKAGE__->has_many(
  "club_enrollments",
  "Koha::Schema::Result::ClubEnrollment",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 course_instructors

Type: has_many

Related object: L<Koha::Schema::Result::CourseInstructor>

=cut

__PACKAGE__->has_many(
  "course_instructors",
  "Koha::Schema::Result::CourseInstructor",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 discharges

Type: has_many

Related object: L<Koha::Schema::Result::Discharge>

=cut

__PACKAGE__->has_many(
  "discharges",
  "Koha::Schema::Result::Discharge",
  { "foreign.borrower" => "self.borrowernumber" },
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

=head2 housebound_profile

Type: might_have

Related object: L<Koha::Schema::Result::HouseboundProfile>

=cut

__PACKAGE__->might_have(
  "housebound_profile",
  "Koha::Schema::Result::HouseboundProfile",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 housebound_role

Type: might_have

Related object: L<Koha::Schema::Result::HouseboundRole>

=cut

__PACKAGE__->might_have(
  "housebound_role",
  "Koha::Schema::Result::HouseboundRole",
  { "foreign.borrowernumber_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 housebound_visit_chooser_brwnumbers

Type: has_many

Related object: L<Koha::Schema::Result::HouseboundVisit>

=cut

__PACKAGE__->has_many(
  "housebound_visit_chooser_brwnumbers",
  "Koha::Schema::Result::HouseboundVisit",
  { "foreign.chooser_brwnumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 housebound_visit_deliverer_brwnumbers

Type: has_many

Related object: L<Koha::Schema::Result::HouseboundVisit>

=cut

__PACKAGE__->has_many(
  "housebound_visit_deliverer_brwnumbers",
  "Koha::Schema::Result::HouseboundVisit",
  { "foreign.deliverer_brwnumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 illrequests

Type: has_many

Related object: L<Koha::Schema::Result::Illrequest>

=cut

__PACKAGE__->has_many(
  "illrequests",
  "Koha::Schema::Result::Illrequest",
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

=head2 items_last_borrowers

Type: has_many

Related object: L<Koha::Schema::Result::ItemsLastBorrower>

=cut

__PACKAGE__->has_many(
  "items_last_borrowers",
  "Koha::Schema::Result::ItemsLastBorrower",
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

=head2 messages

Type: has_many

Related object: L<Koha::Schema::Result::Message>

=cut

__PACKAGE__->has_many(
  "messages",
  "Koha::Schema::Result::Message",
  { "foreign.manager_id" => "self.borrowernumber" },
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

=head2 opac_news

Type: has_many

Related object: L<Koha::Schema::Result::OpacNews>

=cut

__PACKAGE__->has_many(
  "opac_news",
  "Koha::Schema::Result::OpacNews",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 patron_list_patrons

Type: has_many

Related object: L<Koha::Schema::Result::PatronListPatron>

=cut

__PACKAGE__->has_many(
  "patron_list_patrons",
  "Koha::Schema::Result::PatronListPatron",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 patron_lists

Type: has_many

Related object: L<Koha::Schema::Result::PatronList>

=cut

__PACKAGE__->has_many(
  "patron_lists",
  "Koha::Schema::Result::PatronList",
  { "foreign.owner" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 patronimage

Type: might_have

Related object: L<Koha::Schema::Result::Patronimage>

=cut

__PACKAGE__->might_have(
  "patronimage",
  "Koha::Schema::Result::Patronimage",
  { "foreign.borrowernumber" => "self.borrowernumber" },
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

=head2 sms_provider

Type: belongs_to

Related object: L<Koha::Schema::Result::SmsProvider>

=cut

__PACKAGE__->belongs_to(
  "sms_provider",
  "Koha::Schema::Result::SmsProvider",
  { id => "sms_provider_id" },
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

=head2 basketnoes

Type: many_to_many

Composing rels: L</aqbasketusers> -> basketno

=cut

__PACKAGE__->many_to_many("basketnoes", "aqbasketusers", "basketno");

=head2 budgets

Type: many_to_many

Composing rels: L</aqbudgetborrowers> -> budget

=cut

__PACKAGE__->many_to_many("budgets", "aqbudgetborrowers", "budget");

=head2 courses

Type: many_to_many

Composing rels: L</course_instructors> -> course

=cut

__PACKAGE__->many_to_many("courses", "course_instructors", "course");

=head2 ordernumbers

Type: many_to_many

Composing rels: L</aqorder_users> -> ordernumber

=cut

__PACKAGE__->many_to_many("ordernumbers", "aqorder_users", "ordernumber");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-08-30 15:33:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4C4USKLUfuOaydGmIfeOnQ

__PACKAGE__->belongs_to(
    "guarantor",
    "Koha::Schema::Result::Borrower",
    { borrowernumber => "guarantorid" },
);

__PACKAGE__->add_columns(
    '+lost' => { is_boolean => 1 },
    '+gonenoaddress' => { is_boolean => 1 }
);

sub koha_objects_class {
    'Koha::Patrons';
}
sub koha_object_class {
    'Koha::Patron';
}

1;
