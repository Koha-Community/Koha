use utf8;
package Koha::Schema::Result::Aqcontact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqcontact

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqcontacts>

=cut

__PACKAGE__->table("aqcontacts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key and unique number assigned by Koha

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

name of contact at vendor

=head2 position

  data_type: 'varchar'
  is_nullable: 1
  size: 100

contact person's position

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 100

contact's phone number

=head2 altphone

  data_type: 'varchar'
  is_nullable: 1
  size: 100

contact's alternate phone number

=head2 fax

  data_type: 'varchar'
  is_nullable: 1
  size: 100

contact's fax number

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 100

contact's email address

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

notes related to the contact

=head2 orderacquisition

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

should this contact receive acquisition orders

=head2 claimacquisition

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

should this contact receive acquisitions claims

=head2 claimissues

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

should this contact receive serial claims

=head2 acqprimary

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

is this the primary contact for acquisitions messages

=head2 serialsprimary

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

is this the primary contact for serials messages

=head2 booksellerid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "position",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "altphone",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "fax",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
  "orderacquisition",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "claimacquisition",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "claimissues",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "acqprimary",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "serialsprimary",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "booksellerid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 booksellerid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "booksellerid",
  "Koha::Schema::Result::Aqbookseller",
  { id => "booksellerid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IefjqDsoXPLWKSfhYGne1A

__PACKAGE__->add_columns(
    '+orderacquisition' => { is_boolean => 1 },
    '+claimacquisition' => { is_boolean => 1 },
    '+claimissues'      => { is_boolean => 1 },
    '+acqprimary'       => { is_boolean => 1 },
    '+serialsprimary'   => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Acquisition::Bookseller::Contact';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Acquisition::Bookseller::Contacts';
}

1;
