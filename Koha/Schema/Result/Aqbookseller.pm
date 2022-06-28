use utf8;
package Koha::Schema::Result::Aqbookseller;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqbookseller

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbooksellers>

=cut

__PACKAGE__->table("aqbooksellers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key and unique identifier assigned by Koha

=head2 name

  data_type: 'longtext'
  is_nullable: 0

vendor name

=head2 address1

  data_type: 'longtext'
  is_nullable: 1

first line of vendor physical address

=head2 address2

  data_type: 'longtext'
  is_nullable: 1

second line of vendor physical address

=head2 address3

  data_type: 'longtext'
  is_nullable: 1

third line of vendor physical address

=head2 address4

  data_type: 'longtext'
  is_nullable: 1

fourth line of vendor physical address

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 30

vendor phone number

=head2 accountnumber

  data_type: 'longtext'
  is_nullable: 1

vendor account number

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

order notes

=head2 postal

  data_type: 'longtext'
  is_nullable: 1

vendor postal address (all lines)

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

vendor web address

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

is this vendor active (1 for yes, 0 for no)

=head2 listprice

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

currency code for list prices

=head2 invoiceprice

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

currency code for invoice prices

=head2 gstreg

  data_type: 'tinyint'
  is_nullable: 1

is your library charged tax (1 for yes, 0 for no)

=head2 listincgst

  data_type: 'tinyint'
  is_nullable: 1

is tax included in list prices (1 for yes, 0 for no)

=head2 invoiceincgst

  data_type: 'tinyint'
  is_nullable: 1

is tax included in invoice prices (1 for yes, 0 for no)

=head2 tax_rate

  data_type: 'decimal'
  is_nullable: 1
  size: [6,4]

the tax rate the library is charged

=head2 discount

  data_type: 'float'
  is_nullable: 1
  size: [6,4]

discount offered on all items ordered from this vendor

=head2 fax

  data_type: 'varchar'
  is_nullable: 1
  size: 50

vendor fax number

=head2 deliverytime

  data_type: 'integer'
  is_nullable: 1

vendor delivery time

=head2 external_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

external id of the vendor

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "longtext", is_nullable => 0 },
  "address1",
  { data_type => "longtext", is_nullable => 1 },
  "address2",
  { data_type => "longtext", is_nullable => 1 },
  "address3",
  { data_type => "longtext", is_nullable => 1 },
  "address4",
  { data_type => "longtext", is_nullable => 1 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "accountnumber",
  { data_type => "longtext", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
  "postal",
  { data_type => "longtext", is_nullable => 1 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
  "listprice",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "invoiceprice",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "gstreg",
  { data_type => "tinyint", is_nullable => 1 },
  "listincgst",
  { data_type => "tinyint", is_nullable => 1 },
  "invoiceincgst",
  { data_type => "tinyint", is_nullable => 1 },
  "tax_rate",
  { data_type => "decimal", is_nullable => 1, size => [6, 4] },
  "discount",
  { data_type => "float", is_nullable => 1, size => [6, 4] },
  "fax",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "deliverytime",
  { data_type => "integer", is_nullable => 1 },
  "external_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 aqbasketgroups

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasketgroup>

=cut

__PACKAGE__->has_many(
  "aqbasketgroups",
  "Koha::Schema::Result::Aqbasketgroup",
  { "foreign.booksellerid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqbaskets

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasket>

=cut

__PACKAGE__->has_many(
  "aqbaskets",
  "Koha::Schema::Result::Aqbasket",
  { "foreign.booksellerid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqcontacts

Type: has_many

Related object: L<Koha::Schema::Result::Aqcontact>

=cut

__PACKAGE__->has_many(
  "aqcontacts",
  "Koha::Schema::Result::Aqcontact",
  { "foreign.booksellerid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqcontracts

Type: has_many

Related object: L<Koha::Schema::Result::Aqcontract>

=cut

__PACKAGE__->has_many(
  "aqcontracts",
  "Koha::Schema::Result::Aqcontract",
  { "foreign.booksellerid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqinvoices

Type: has_many

Related object: L<Koha::Schema::Result::Aqinvoice>

=cut

__PACKAGE__->has_many(
  "aqinvoices",
  "Koha::Schema::Result::Aqinvoice",
  { "foreign.booksellerid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 edifact_messages

Type: has_many

Related object: L<Koha::Schema::Result::EdifactMessage>

=cut

__PACKAGE__->has_many(
  "edifact_messages",
  "Koha::Schema::Result::EdifactMessage",
  { "foreign.vendor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_agreements

Type: has_many

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->has_many(
  "erm_agreements",
  "Koha::Schema::Result::ErmAgreement",
  { "foreign.vendor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_eholdings_packages

Type: has_many

Related object: L<Koha::Schema::Result::ErmEholdingsPackage>

=cut

__PACKAGE__->has_many(
  "erm_eholdings_packages",
  "Koha::Schema::Result::ErmEholdingsPackage",
  { "foreign.vendor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_eholdings_resources

Type: has_many

Related object: L<Koha::Schema::Result::ErmEholdingsResource>

=cut

__PACKAGE__->has_many(
  "erm_eholdings_resources",
  "Koha::Schema::Result::ErmEholdingsResource",
  { "foreign.vendor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_licenses

Type: has_many

Related object: L<Koha::Schema::Result::ErmLicense>

=cut

__PACKAGE__->has_many(
  "erm_licenses",
  "Koha::Schema::Result::ErmLicense",
  { "foreign.vendor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 invoiceprice

Type: belongs_to

Related object: L<Koha::Schema::Result::Currency>

=cut

__PACKAGE__->belongs_to(
  "invoiceprice",
  "Koha::Schema::Result::Currency",
  { currency => "invoiceprice" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 listprice

Type: belongs_to

Related object: L<Koha::Schema::Result::Currency>

=cut

__PACKAGE__->belongs_to(
  "listprice",
  "Koha::Schema::Result::Currency",
  { currency => "listprice" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 vendor_edi_accounts

Type: has_many

Related object: L<Koha::Schema::Result::VendorEdiAccount>

=cut

__PACKAGE__->has_many(
  "vendor_edi_accounts",
  "Koha::Schema::Result::VendorEdiAccount",
  { "foreign.vendor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-19 09:20:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Xxg454HATZToWE01NY8eJw

__PACKAGE__->add_columns(
    '+active' => { is_boolean => 1 },
    '+gstreg' => { is_boolean => 1 },
    '+listincgst' => { is_boolean => 1 },
    '+invoiceincgst' => { is_boolean => 1 },
);

sub koha_object_class {
    'Koha::Acquisition::Bookseller';
}
sub koha_objects_class {
    'Koha::Acquisition::Booksellers';
}

1;
