package Koha::Schema::Result::Z3950server;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Z3950server

=cut

__PACKAGE__->table("z3950servers");

=head1 ACCESSORS

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

=head2 name

  data_type: 'mediumtext'
  is_nullable: 1

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
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

=head2 icon

  data_type: 'text'
  is_nullable: 1

=head2 position

  data_type: 'enum'
  default_value: 'primary'
  extra: {list => ["primary","secondary",""]}
  is_nullable: 0

=head2 type

  data_type: 'enum'
  default_value: 'zed'
  extra: {list => ["zed","opensearch"]}
  is_nullable: 0

=head2 encoding

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
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
  "name",
  { data_type => "mediumtext", is_nullable => 1 },
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "checked",
  { data_type => "smallint", is_nullable => 1 },
  "rank",
  { data_type => "integer", is_nullable => 1 },
  "syntax",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "timeout",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "icon",
  { data_type => "text", is_nullable => 1 },
  "position",
  {
    data_type => "enum",
    default_value => "primary",
    extra => { list => ["primary", "secondary", ""] },
    is_nullable => 0,
  },
  "type",
  {
    data_type => "enum",
    default_value => "zed",
    extra => { list => ["zed", "opensearch"] },
    is_nullable => 0,
  },
  "encoding",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3D8BWcZZVQlK8zrPw4GTtQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
