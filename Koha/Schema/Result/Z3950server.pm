use utf8;
package Koha::Schema::Result::Z3950server;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Z3950server

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<z3950servers>

=cut

__PACKAGE__->table("z3950servers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 host

  data_type: 'varchar'
  is_nullable: 0
  size: 255

target's host name

=head2 port

  data_type: 'integer'
  is_nullable: 1

port number used to connect to target

=head2 db

  data_type: 'varchar'
  is_nullable: 1
  size: 255

target's database name

=head2 userid

  data_type: 'varchar'
  is_nullable: 1
  size: 255

username needed to log in to target

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 255

password needed to log in to target

=head2 servername

  data_type: 'longtext'
  is_nullable: 0

name given to the target by the library

=head2 checked

  data_type: 'smallint'
  is_nullable: 1

whether this target is checked by default  (1 for yes, 0 for no)

=head2 rank

  data_type: 'integer'
  is_nullable: 1

where this target appears in the list of targets

=head2 syntax

  data_type: 'varchar'
  is_nullable: 0
  size: 80

MARC format provided by this target

=head2 timeout

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

number of seconds before Koha stops trying to access this server

=head2 servertype

  data_type: 'enum'
  default_value: 'zed'
  extra: {list => ["zed","sru"]}
  is_nullable: 0

zed means z39.50 server

=head2 encoding

  data_type: 'mediumtext'
  is_nullable: 0

characters encoding provided by this target

=head2 recordtype

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["authority","biblio"]}
  is_nullable: 0

server contains bibliographic or authority records

=head2 sru_options

  data_type: 'varchar'
  is_nullable: 1
  size: 255

options like sru=get, sru_version=1.1; will be passed to the server via ZOOM

=head2 sru_fields

  data_type: 'longtext'
  is_nullable: 1

contains the mapping between the Z3950 search fields and the specific SRU server indexes

=head2 add_xslt

  data_type: 'longtext'
  is_nullable: 1

zero or more paths to XSLT files to be processed on the search results

=head2 attributes

  data_type: 'varchar'
  is_nullable: 1
  size: 255

additional attributes passed to PQF queries

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "host",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "port",
  { data_type => "integer", is_nullable => 1 },
  "db",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "userid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "servername",
  { data_type => "longtext", is_nullable => 0 },
  "checked",
  { data_type => "smallint", is_nullable => 1 },
  "rank",
  { data_type => "integer", is_nullable => 1 },
  "syntax",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "timeout",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "servertype",
  {
    data_type => "enum",
    default_value => "zed",
    extra => { list => ["zed", "sru"] },
    is_nullable => 0,
  },
  "encoding",
  { data_type => "mediumtext", is_nullable => 0 },
  "recordtype",
  {
    data_type => "enum",
    default_value => "biblio",
    extra => { list => ["authority", "biblio"] },
    is_nullable => 0,
  },
  "sru_options",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sru_fields",
  { data_type => "longtext", is_nullable => 1 },
  "add_xslt",
  { data_type => "longtext", is_nullable => 1 },
  "attributes",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-03 11:30:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1uIZOogM1tV2M7fbpPRDwg

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Z3950Server';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Z3950Servers';
}

1;
