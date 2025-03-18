use utf8;
package Koha::Schema::Result::OaiServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OaiServer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<oai_servers>

=cut

__PACKAGE__->table("oai_servers");

=head1 ACCESSORS

=head2 oai_server_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 endpoint

  data_type: 'varchar'
  is_nullable: 0
  size: 255

OAI endpoint (host + port + path)

=head2 oai_set

  data_type: 'varchar'
  is_nullable: 1
  size: 255

OAI set to harvest

=head2 servername

  data_type: 'longtext'
  is_nullable: 0

name given to the target by the library

=head2 dataformat

  data_type: 'enum'
  default_value: 'oai_dc'
  extra: {list => ["oai_dc","marc-xml","marcxml"]}
  is_nullable: 0

data format

=head2 recordtype

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["authority","biblio"]}
  is_nullable: 0

server contains bibliographic or authority records

=head2 add_xslt

  data_type: 'longtext'
  is_nullable: 1

zero or more paths to XSLT files to be processed on the search results

=cut

__PACKAGE__->add_columns(
  "oai_server_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "endpoint",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "oai_set",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "servername",
  { data_type => "longtext", is_nullable => 0 },
  "dataformat",
  {
    data_type => "enum",
    default_value => "oai_dc",
    extra => { list => ["oai_dc", "marc-xml", "marcxml"] },
    is_nullable => 0,
  },
  "recordtype",
  {
    data_type => "enum",
    default_value => "biblio",
    extra => { list => ["authority", "biblio"] },
    is_nullable => 0,
  },
  "add_xslt",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</oai_server_id>

=back

=cut

__PACKAGE__->set_primary_key("oai_server_id");


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-07-31 14:51:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HeQgY+4P10NKCtLqdExv+g

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::OAIServer';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::OAIServers';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
