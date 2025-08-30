use utf8;
package Koha::Schema::Result::FileTransport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::FileTransport

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<file_transports>

=cut

__PACKAGE__->table("file_transports");

=head1 ACCESSORS

=head2 file_transport_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 host

  data_type: 'varchar'
  default_value: 'localhost'
  is_nullable: 0
  size: 80

=head2 port

  data_type: 'integer'
  default_value: 22
  is_nullable: 0

=head2 transport

  data_type: 'enum'
  default_value: 'sftp'
  extra: {list => ["ftp","sftp"]}
  is_nullable: 0

=head2 passive

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 user_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 password

  data_type: 'mediumtext'
  is_nullable: 1

=head2 key_file

  data_type: 'mediumtext'
  is_nullable: 1

=head2 auth_mode

  data_type: 'enum'
  default_value: 'password'
  extra: {list => ["password","key_file","noauth"]}
  is_nullable: 0

=head2 download_directory

  data_type: 'mediumtext'
  is_nullable: 1

=head2 upload_directory

  data_type: 'mediumtext'
  is_nullable: 1

=head2 status

  data_type: 'longtext'
  is_nullable: 1

=head2 debug

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "file_transport_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "host",
  {
    data_type => "varchar",
    default_value => "localhost",
    is_nullable => 0,
    size => 80,
  },
  "port",
  { data_type => "integer", default_value => 22, is_nullable => 0 },
  "transport",
  {
    data_type => "enum",
    default_value => "sftp",
    extra => { list => ["ftp", "sftp"] },
    is_nullable => 0,
  },
  "passive",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "user_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "password",
  { data_type => "mediumtext", is_nullable => 1 },
  "key_file",
  { data_type => "mediumtext", is_nullable => 1 },
  "auth_mode",
  {
    data_type => "enum",
    default_value => "password",
    extra => { list => ["password", "key_file", "noauth"] },
    is_nullable => 0,
  },
  "download_directory",
  { data_type => "mediumtext", is_nullable => 1 },
  "upload_directory",
  { data_type => "mediumtext", is_nullable => 1 },
  "status",
  { data_type => "longtext", is_nullable => 1 },
  "debug",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</file_transport_id>

=back

=cut

__PACKAGE__->set_primary_key("file_transport_id");


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-09-15 14:28:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Mpw0xCAH2Jmoxv3V9fHJRw

__PACKAGE__->add_columns(
    '+passive' => { is_boolean => 1 },
    '+debug'   => { is_boolean => 1 },
);

=head2 koha_objects_class

Helper for Koha::Object-based class name resolution.

=cut

sub koha_objects_class {
    'Koha::File::Transports';
}

=head2 koha_object_class

Helper for Koha::Object-based class name resolution.

=cut

sub koha_object_class {
    'Koha::File::Transport';
}

1;
