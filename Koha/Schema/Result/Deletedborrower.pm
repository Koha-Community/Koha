use utf8;
package Koha::Schema::Result::Deletedborrower;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Deletedborrower

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<deletedborrowers>

=cut

__PACKAGE__->table("deletedborrowers");

=head1 ACCESSORS

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
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
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
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
  { data_type => "integer", default_value => 0, is_nullable => 0 },
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
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "categorycode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
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
  { data_type => "integer", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DNkNHNcv0lkMH6/seu89hg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
