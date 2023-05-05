use utf8;
package Koha::Schema::Result::AqbooksellerInterface;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqbooksellerInterface

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbookseller_interfaces>

=cut

__PACKAGE__->table("aqbookseller_interfaces");

=head1 ACCESSORS

=head2 interface_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key and unique identifier assigned by Koha

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the vendor

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

type of the interface, authorised value VENDOR_INTERFACE_TYPE

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

name of the interface

=head2 uri

  data_type: 'mediumtext'
  is_nullable: 1

uri of the interface

=head2 login

  data_type: 'varchar'
  is_nullable: 1
  size: 255

login

=head2 password

  data_type: 'mediumtext'
  is_nullable: 1

hashed password

=head2 account_email

  data_type: 'mediumtext'
  is_nullable: 1

account email

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

notes

=cut

__PACKAGE__->add_columns(
  "interface_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "uri",
  { data_type => "mediumtext", is_nullable => 1 },
  "login",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "password",
  { data_type => "mediumtext", is_nullable => 1 },
  "account_email",
  { data_type => "mediumtext", is_nullable => 1 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</interface_id>

=back

=cut

__PACKAGE__->set_primary_key("interface_id");

=head1 RELATIONS

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-05 12:54:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NOk5VsJp5v7nTw39qxrEbw

sub koha_object_class {
    'Koha::Acquisition::Bookseller::Interface';
}
sub koha_objects_class {
    'Koha::Acquisition::Bookseller::Interfaces';
}

1;
