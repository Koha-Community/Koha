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

primary key, Koha assigned ID number for patrons/borrowers

=head2 cardnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 32

unique key, library assigned ID number for patrons/borrowers

=head2 surname

  data_type: 'longtext'
  is_nullable: 1

patron/borrower's last name (surname)

=head2 firstname

  data_type: 'mediumtext'
  is_nullable: 1

patron/borrower's first name

=head2 middle_name

  data_type: 'longtext'
  is_nullable: 1

patron/borrower's middle name

=head2 title

  data_type: 'longtext'
  is_nullable: 1

patron/borrower's title, for example: Mr. or Mrs.

=head2 othernames

  data_type: 'longtext'
  is_nullable: 1

any other names associated with the patron/borrower

=head2 initials

  data_type: 'mediumtext'
  is_nullable: 1

initials for your patron/borrower

=head2 pronouns

  data_type: 'longtext'
  is_nullable: 1

patron/borrower pronouns

=head2 streetnumber

  data_type: 'tinytext'
  is_nullable: 1

the house number for your patron/borrower's primary address

=head2 streettype

  data_type: 'tinytext'
  is_nullable: 1

the street type (Rd., Blvd, etc) for your patron/borrower's primary address

=head2 address

  data_type: 'longtext'
  is_nullable: 1

the first address line for your patron/borrower's primary address

=head2 address2

  data_type: 'mediumtext'
  is_nullable: 1

the second address line for your patron/borrower's primary address

=head2 city

  data_type: 'longtext'
  is_nullable: 1

the city or town for your patron/borrower's primary address

=head2 state

  data_type: 'mediumtext'
  is_nullable: 1

the state or province for your patron/borrower's primary address

=head2 zipcode

  data_type: 'tinytext'
  is_nullable: 1

the zip or postal code for your patron/borrower's primary address

=head2 country

  data_type: 'mediumtext'
  is_nullable: 1

the country for your patron/borrower's primary address

=head2 email

  data_type: 'longtext'
  is_nullable: 1

the primary email address for your patron/borrower's primary address

=head2 phone

  data_type: 'mediumtext'
  is_nullable: 1

the primary phone number for your patron/borrower's primary address

=head2 mobile

  data_type: 'tinytext'
  is_nullable: 1

the other phone number for your patron/borrower's primary address

=head2 fax

  data_type: 'longtext'
  is_nullable: 1

the fax number for your patron/borrower's primary address

=head2 emailpro

  data_type: 'mediumtext'
  is_nullable: 1

the secondary email addres for your patron/borrower's primary address

=head2 phonepro

  data_type: 'mediumtext'
  is_nullable: 1

the secondary phone number for your patron/borrower's primary address

=head2 B_streetnumber

  accessor: 'b_streetnumber'
  data_type: 'tinytext'
  is_nullable: 1

the house number for your patron/borrower's alternate address

=head2 B_streettype

  accessor: 'b_streettype'
  data_type: 'tinytext'
  is_nullable: 1

the street type (Rd., Blvd, etc) for your patron/borrower's alternate address

=head2 B_address

  accessor: 'b_address'
  data_type: 'mediumtext'
  is_nullable: 1

the first address line for your patron/borrower's alternate address

=head2 B_address2

  accessor: 'b_address2'
  data_type: 'mediumtext'
  is_nullable: 1

the second address line for your patron/borrower's alternate address

=head2 B_city

  accessor: 'b_city'
  data_type: 'longtext'
  is_nullable: 1

the city or town for your patron/borrower's alternate address

=head2 B_state

  accessor: 'b_state'
  data_type: 'mediumtext'
  is_nullable: 1

the state for your patron/borrower's alternate address

=head2 B_zipcode

  accessor: 'b_zipcode'
  data_type: 'tinytext'
  is_nullable: 1

the zip or postal code for your patron/borrower's alternate address

=head2 B_country

  accessor: 'b_country'
  data_type: 'mediumtext'
  is_nullable: 1

the country for your patron/borrower's alternate address

=head2 B_email

  accessor: 'b_email'
  data_type: 'mediumtext'
  is_nullable: 1

the patron/borrower's alternate email address

=head2 B_phone

  accessor: 'b_phone'
  data_type: 'longtext'
  is_nullable: 1

the patron/borrower's alternate phone number

=head2 dateofbirth

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the patron/borrower's date of birth (YYYY-MM-DD)

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

foreign key from the branches table, includes the code of the patron/borrower's home branch

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

foreign key from the categories table, includes the code of the patron category

=head2 dateenrolled

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the patron was added to Koha (YYYY-MM-DD)

=head2 dateexpiry

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the patron/borrower's card is set to expire (YYYY-MM-DD)

=head2 password_expiration_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the patron/borrower's password is set to expire (YYYY-MM-DD)

=head2 date_renewed

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the patron/borrower's card was last renewed

=head2 gonenoaddress

  data_type: 'tinyint'
  is_nullable: 1

set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having an unconfirmed address

=head2 lost

  data_type: 'tinyint'
  is_nullable: 1

set to 1 for yes and 0 for no, flag to note that library marked this patron/borrower as having lost their card

=head2 debarred

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

until this date the patron can only check-in (no loans, no holds, etc.), is a fine based on days instead of money (YYYY-MM-DD)

=head2 debarredcomment

  data_type: 'varchar'
  is_nullable: 1
  size: 255

comment on the stop of patron

=head2 contactname

  data_type: 'longtext'
  is_nullable: 1

used for children and profesionals to include surname or last name of guarantor or organization name

=head2 contactfirstname

  data_type: 'mediumtext'
  is_nullable: 1

used for children to include first name of guarantor

=head2 contacttitle

  data_type: 'mediumtext'
  is_nullable: 1

used for children to include title (Mr., Mrs., etc) of guarantor

=head2 borrowernotes

  data_type: 'longtext'
  is_nullable: 1

a note on the patron/borrower's account that is only visible in the staff interface

=head2 relationship

  data_type: 'varchar'
  is_nullable: 1
  size: 100

used for children to include the relationship to their guarantor

=head2 sex

  data_type: 'varchar'
  is_nullable: 1
  size: 1

patron/borrower's gender

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 60

patron/borrower's encrypted password

=head2 secret

  data_type: 'mediumtext'
  is_nullable: 1

Secret for 2FA

=head2 auth_method

  data_type: 'enum'
  default_value: 'password'
  extra: {list => ["password","two-factor"]}
  is_nullable: 0

Authentication method

=head2 flags

  data_type: 'bigint'
  is_nullable: 1

will include a number associated with the staff member's permissions

=head2 userid

  data_type: 'varchar'
  is_nullable: 1
  size: 75

patron/borrower's opac and/or staff interface log in

=head2 opacnote

  data_type: 'longtext'
  is_nullable: 1

a note on the patron/borrower's account that is visible in the OPAC and staff interface

=head2 contactnote

  data_type: 'varchar'
  is_nullable: 1
  size: 255

a note related to the patron/borrower's alternate address

=head2 sort1

  data_type: 'varchar'
  is_nullable: 1
  size: 80

a field that can be used for any information unique to the library

=head2 sort2

  data_type: 'varchar'
  is_nullable: 1
  size: 80

a field that can be used for any information unique to the library

=head2 altcontactfirstname

  data_type: 'mediumtext'
  is_nullable: 1

first name of alternate contact for the patron/borrower

=head2 altcontactsurname

  data_type: 'mediumtext'
  is_nullable: 1

surname or last name of the alternate contact for the patron/borrower

=head2 altcontactaddress1

  data_type: 'mediumtext'
  is_nullable: 1

the first address line for the alternate contact for the patron/borrower

=head2 altcontactaddress2

  data_type: 'mediumtext'
  is_nullable: 1

the second address line for the alternate contact for the patron/borrower

=head2 altcontactaddress3

  data_type: 'mediumtext'
  is_nullable: 1

the city for the alternate contact for the patron/borrower

=head2 altcontactstate

  data_type: 'mediumtext'
  is_nullable: 1

the state for the alternate contact for the patron/borrower

=head2 altcontactzipcode

  data_type: 'mediumtext'
  is_nullable: 1

the zipcode for the alternate contact for the patron/borrower

=head2 altcontactcountry

  data_type: 'mediumtext'
  is_nullable: 1

the country for the alternate contact for the patron/borrower

=head2 altcontactphone

  data_type: 'mediumtext'
  is_nullable: 1

the phone number for the alternate contact for the patron/borrower

=head2 smsalertnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 50

the mobile phone number where the patron/borrower would like to receive notices (if SMS turned on)

=head2 sms_provider_id

  data_type: 'integer'
  is_nullable: 1

the provider of the mobile phone number defined in smsalertnumber

=head2 privacy

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

patron/borrower's privacy settings related to their checkout history  KEY `borrowernumber` (`borrowernumber`),

=head2 privacy_guarantor_fines

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

controls if relatives can see this patron's fines

=head2 privacy_guarantor_checkouts

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

controls if relatives can see this patron's checkouts

=head2 checkprevcheckout

  data_type: 'varchar'
  default_value: 'inherit'
  is_nullable: 0
  size: 7

produce a warning for this patron if this item has previously been checked out to this patron if 'yes', not if 'no', defer to category setting if 'inherit'.

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

time of last change could be useful for synchronization with external systems (among others)

=head2 lastseen

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

last time a patron has been seen (connected at the OPAC or staff interface)

=head2 lang

  data_type: 'varchar'
  default_value: 'default'
  is_nullable: 0
  size: 25

lang to use to send notices to this patron

=head2 login_attempts

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

number of failed login attemps

=head2 overdrive_auth_token

  data_type: 'mediumtext'
  is_nullable: 1

persist OverDrive auth token

=head2 anonymized

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

flag for data anonymization

=head2 autorenew_checkouts

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

flag for allowing auto-renewal

=head2 primary_contact_method

  data_type: 'varchar'
  is_nullable: 1
  size: 45

useful for reporting purposes

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
  "middle_name",
  { data_type => "longtext", is_nullable => 1 },
  "title",
  { data_type => "longtext", is_nullable => 1 },
  "othernames",
  { data_type => "longtext", is_nullable => 1 },
  "initials",
  { data_type => "mediumtext", is_nullable => 1 },
  "pronouns",
  { data_type => "longtext", is_nullable => 1 },
  "streetnumber",
  { data_type => "tinytext", is_nullable => 1 },
  "streettype",
  { data_type => "tinytext", is_nullable => 1 },
  "address",
  { data_type => "longtext", is_nullable => 1 },
  "address2",
  { data_type => "mediumtext", is_nullable => 1 },
  "city",
  { data_type => "longtext", is_nullable => 1 },
  "state",
  { data_type => "mediumtext", is_nullable => 1 },
  "zipcode",
  { data_type => "tinytext", is_nullable => 1 },
  "country",
  { data_type => "mediumtext", is_nullable => 1 },
  "email",
  { data_type => "longtext", is_nullable => 1 },
  "phone",
  { data_type => "mediumtext", is_nullable => 1 },
  "mobile",
  { data_type => "tinytext", is_nullable => 1 },
  "fax",
  { data_type => "longtext", is_nullable => 1 },
  "emailpro",
  { data_type => "mediumtext", is_nullable => 1 },
  "phonepro",
  { data_type => "mediumtext", is_nullable => 1 },
  "B_streetnumber",
  { accessor => "b_streetnumber", data_type => "tinytext", is_nullable => 1 },
  "B_streettype",
  { accessor => "b_streettype", data_type => "tinytext", is_nullable => 1 },
  "B_address",
  { accessor => "b_address", data_type => "mediumtext", is_nullable => 1 },
  "B_address2",
  { accessor => "b_address2", data_type => "mediumtext", is_nullable => 1 },
  "B_city",
  { accessor => "b_city", data_type => "longtext", is_nullable => 1 },
  "B_state",
  { accessor => "b_state", data_type => "mediumtext", is_nullable => 1 },
  "B_zipcode",
  { accessor => "b_zipcode", data_type => "tinytext", is_nullable => 1 },
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
  "password_expiration_date",
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
  "borrowernotes",
  { data_type => "longtext", is_nullable => 1 },
  "relationship",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "sex",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "secret",
  { data_type => "mediumtext", is_nullable => 1 },
  "auth_method",
  {
    data_type => "enum",
    default_value => "password",
    extra => { list => ["password", "two-factor"] },
    is_nullable => 0,
  },
  "flags",
  { data_type => "bigint", is_nullable => 1 },
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
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactsurname",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactaddress1",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactaddress2",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactaddress3",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactstate",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactzipcode",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactcountry",
  { data_type => "mediumtext", is_nullable => 1 },
  "altcontactphone",
  { data_type => "mediumtext", is_nullable => 1 },
  "smsalertnumber",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "sms_provider_id",
  { data_type => "integer", is_nullable => 1 },
  "privacy",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "privacy_guarantor_fines",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
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
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "overdrive_auth_token",
  { data_type => "mediumtext", is_nullable => 1 },
  "anonymized",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "autorenew_checkouts",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "primary_contact_method",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-06 15:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dqGu9iDgO+u09l9X1G0NuA

__PACKAGE__->add_columns(
    '+anonymized'    => { is_boolean => 1 },
    '+lost'          => { is_boolean => 1 },
    '+gonenoaddress' => { is_boolean => 1 },
    '+privacy_guarantor_fines' => { is_boolean => 1 },
    '+autorenew_checkouts' => { is_boolean => 1 }
);

sub koha_objects_class {
    'Koha::Old::Patrons';
}
sub koha_object_class {
    'Koha::Old::Patron';
}

1;
