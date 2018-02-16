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

=head2 host

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 port

  data_type: 'integer'
  is_nullable: 1

=head2 db

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 userid

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 servername

  data_type: 'longtext'
  is_nullable: 0

=head2 checked

  data_type: 'smallint'
  is_nullable: 1

=head2 rank

  data_type: 'integer'
  is_nullable: 1

=head2 syntax

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 timeout

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 servertype

  data_type: 'enum'
  default_value: 'zed'
  extra: {list => ["zed","sru"]}
  is_nullable: 0

=head2 encoding

  data_type: 'mediumtext'
  is_nullable: 1

=head2 recordtype

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["authority","biblio"]}
  is_nullable: 0

=head2 sru_options

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 sru_fields

  data_type: 'longtext'
  is_nullable: 1

=head2 add_xslt

  data_type: 'longtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "host",
  { data_type => "varchar", is_nullable => 1, size => 255 },
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
  { data_type => "varchar", is_nullable => 1, size => 80 },
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
  { data_type => "mediumtext", is_nullable => 1 },
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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KK2y1pbgVh1hOVLAXL1e/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
