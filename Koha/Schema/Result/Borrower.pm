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
  is_foreign_key: 1
  is_nullable: 0
  size: 10

foreign key from the branches table, includes the code of the patron/borrower's home branch

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
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

comment on the stop of the patron

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

patron/borrower's Bcrypt encrypted password

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
  is_foreign_key: 1
  is_nullable: 1

the provider of the mobile phone number defined in smsalertnumber

=head2 privacy

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

patron/borrower's privacy settings related to their checkout history

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
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
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
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

=head2 accountlines_managers

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines_managers",
  "Koha::Schema::Result::Accountline",
  { "foreign.manager_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 additional_contents

Type: has_many

Related object: L<Koha::Schema::Result::AdditionalContent>

=cut

__PACKAGE__->has_many(
  "additional_contents",
  "Koha::Schema::Result::AdditionalContent",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 advanced_editor_macros

Type: has_many

Related object: L<Koha::Schema::Result::AdvancedEditorMacro>

=cut

__PACKAGE__->has_many(
  "advanced_editor_macros",
  "Koha::Schema::Result::AdvancedEditorMacro",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 alerts

Type: has_many

Related object: L<Koha::Schema::Result::Alert>

=cut

__PACKAGE__->has_many(
  "alerts",
  "Koha::Schema::Result::Alert",
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

=head2 borrower_relationships_guarantees

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerRelationship>

=cut

__PACKAGE__->has_many(
  "borrower_relationships_guarantees",
  "Koha::Schema::Result::BorrowerRelationship",
  { "foreign.guarantee_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_relationships_guarantors

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerRelationship>

=cut

__PACKAGE__->has_many(
  "borrower_relationships_guarantors",
  "Koha::Schema::Result::BorrowerRelationship",
  { "foreign.guarantor_id" => "self.borrowernumber" },
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

=head2 cash_register_actions

Type: has_many

Related object: L<Koha::Schema::Result::CashRegisterAction>

=cut

__PACKAGE__->has_many(
  "cash_register_actions",
  "Koha::Schema::Result::CashRegisterAction",
  { "foreign.manager_id" => "self.borrowernumber" },
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
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 checkout_renewals

Type: has_many

Related object: L<Koha::Schema::Result::CheckoutRenewal>

=cut

__PACKAGE__->has_many(
  "checkout_renewals",
  "Koha::Schema::Result::CheckoutRenewal",
  { "foreign.renewer_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 club_holds_to_patron_holds

Type: has_many

Related object: L<Koha::Schema::Result::ClubHoldsToPatronHold>

=cut

__PACKAGE__->has_many(
  "club_holds_to_patron_holds",
  "Koha::Schema::Result::ClubHoldsToPatronHold",
  { "foreign.patron_id" => "self.borrowernumber" },
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

=head2 curbside_pickups_borrowernumbers

Type: has_many

Related object: L<Koha::Schema::Result::CurbsidePickup>

=cut

__PACKAGE__->has_many(
  "curbside_pickups_borrowernumbers",
  "Koha::Schema::Result::CurbsidePickup",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 curbside_pickups_staged_by

Type: has_many

Related object: L<Koha::Schema::Result::CurbsidePickup>

=cut

__PACKAGE__->has_many(
  "curbside_pickups_staged_by",
  "Koha::Schema::Result::CurbsidePickup",
  { "foreign.staged_by" => "self.borrowernumber" },
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

=head2 erm_user_roles

Type: has_many

Related object: L<Koha::Schema::Result::ErmUserRole>

=cut

__PACKAGE__->has_many(
  "erm_user_roles",
  "Koha::Schema::Result::ErmUserRole",
  { "foreign.user_id" => "self.borrowernumber" },
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

=head2 illbatches

Type: has_many

Related object: L<Koha::Schema::Result::Illbatch>

=cut

__PACKAGE__->has_many(
  "illbatches",
  "Koha::Schema::Result::Illbatch",
  { "foreign.patron_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 illcomments

Type: has_many

Related object: L<Koha::Schema::Result::Illcomment>

=cut

__PACKAGE__->has_many(
  "illcomments",
  "Koha::Schema::Result::Illcomment",
  { "foreign.borrowernumber" => "self.borrowernumber" },
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

=head2 issues_issuers

Type: has_many

Related object: L<Koha::Schema::Result::Issue>

=cut

__PACKAGE__->has_many(
  "issues_issuers",
  "Koha::Schema::Result::Issue",
  { "foreign.issuer_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 item_editor_templates

Type: has_many

Related object: L<Koha::Schema::Result::ItemEditorTemplate>

=cut

__PACKAGE__->has_many(
  "item_editor_templates",
  "Koha::Schema::Result::ItemEditorTemplate",
  { "foreign.patron_id" => "self.borrowernumber" },
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

=head2 linktrackers

Type: has_many

Related object: L<Koha::Schema::Result::Linktracker>

=cut

__PACKAGE__->has_many(
  "linktrackers",
  "Koha::Schema::Result::Linktracker",
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

=head2 messages_borrowernumbers

Type: has_many

Related object: L<Koha::Schema::Result::Message>

=cut

__PACKAGE__->has_many(
  "messages_borrowernumbers",
  "Koha::Schema::Result::Message",
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

=head2 old_issues_issuers

Type: has_many

Related object: L<Koha::Schema::Result::OldIssue>

=cut

__PACKAGE__->has_many(
  "old_issues_issuers",
  "Koha::Schema::Result::OldIssue",
  { "foreign.issuer_id" => "self.borrowernumber" },
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

=head2 patron_consents

Type: has_many

Related object: L<Koha::Schema::Result::PatronConsent>

=cut

__PACKAGE__->has_many(
  "patron_consents",
  "Koha::Schema::Result::PatronConsent",
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

=head2 problem_reports

Type: has_many

Related object: L<Koha::Schema::Result::ProblemReport>

=cut

__PACKAGE__->has_many(
  "problem_reports",
  "Koha::Schema::Result::ProblemReport",
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

=head2 recalls

Type: has_many

Related object: L<Koha::Schema::Result::Recall>

=cut

__PACKAGE__->has_many(
  "recalls",
  "Koha::Schema::Result::Recall",
  { "foreign.patron_id" => "self.borrowernumber" },
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

=head2 return_claims_borrowernumbers

Type: has_many

Related object: L<Koha::Schema::Result::ReturnClaim>

=cut

__PACKAGE__->has_many(
  "return_claims_borrowernumbers",
  "Koha::Schema::Result::ReturnClaim",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 return_claims_created_by

Type: has_many

Related object: L<Koha::Schema::Result::ReturnClaim>

=cut

__PACKAGE__->has_many(
  "return_claims_created_by",
  "Koha::Schema::Result::ReturnClaim",
  { "foreign.created_by" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 return_claims_resolved_by

Type: has_many

Related object: L<Koha::Schema::Result::ReturnClaim>

=cut

__PACKAGE__->has_many(
  "return_claims_resolved_by",
  "Koha::Schema::Result::ReturnClaim",
  { "foreign.resolved_by" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 return_claims_updated_by

Type: has_many

Related object: L<Koha::Schema::Result::ReturnClaim>

=cut

__PACKAGE__->has_many(
  "return_claims_updated_by",
  "Koha::Schema::Result::ReturnClaim",
  { "foreign.updated_by" => "self.borrowernumber" },
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

=head2 suggestions_acceptedbies

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions_acceptedbies",
  "Koha::Schema::Result::Suggestion",
  { "foreign.acceptedby" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 suggestions_lastmodificationbies

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions_lastmodificationbies",
  "Koha::Schema::Result::Suggestion",
  { "foreign.lastmodificationby" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 suggestions_managedbies

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions_managedbies",
  "Koha::Schema::Result::Suggestion",
  { "foreign.managedby" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 suggestions_rejectedbies

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions_rejectedbies",
  "Koha::Schema::Result::Suggestion",
  { "foreign.rejectedby" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 suggestions_suggestedbies

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions_suggestedbies",
  "Koha::Schema::Result::Suggestion",
  { "foreign.suggestedby" => "self.borrowernumber" },
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

=head2 ticket_updates

Type: has_many

Related object: L<Koha::Schema::Result::TicketUpdate>

=cut

__PACKAGE__->has_many(
  "ticket_updates",
  "Koha::Schema::Result::TicketUpdate",
  { "foreign.user_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tickets_reporters

Type: has_many

Related object: L<Koha::Schema::Result::Ticket>

=cut

__PACKAGE__->has_many(
  "tickets_reporters",
  "Koha::Schema::Result::Ticket",
  { "foreign.reporter_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tickets_resolvers

Type: has_many

Related object: L<Koha::Schema::Result::Ticket>

=cut

__PACKAGE__->has_many(
  "tickets_resolvers",
  "Koha::Schema::Result::Ticket",
  { "foreign.resolver_id" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tmp_holdsqueues

Type: has_many

Related object: L<Koha::Schema::Result::TmpHoldsqueue>

=cut

__PACKAGE__->has_many(
  "tmp_holdsqueues",
  "Koha::Schema::Result::TmpHoldsqueue",
  { "foreign.borrowernumber" => "self.borrowernumber" },
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

=head2 permissions

Type: many_to_many

Composing rels: L</user_permissions> -> permission

=cut

__PACKAGE__->many_to_many("permissions", "user_permissions", "permission");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-10 14:16:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nIMnqyBVBam7NvIx4aDfHw

__PACKAGE__->has_many(
  "restrictions",
  "Koha::Schema::Result::BorrowerDebarment",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "extended_attributes",
  "Koha::Schema::Result::BorrowerAttribute",
  { "foreign.borrowernumber" => "self.borrowernumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    '+anonymized'    => { is_boolean => 1 },
    '+lost'          => { is_boolean => 1 },
    '+gonenoaddress' => { is_boolean => 1 },
    '+privacy_guarantor_fines' => { is_boolean => 1 },
    '+autorenew_checkouts' => { is_boolean => 1 }
);

sub koha_objects_class {
    'Koha::Patrons';
}
sub koha_object_class {
    'Koha::Patron';
}

1;
