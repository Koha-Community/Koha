use utf8;
package Koha::Schema::Result::SmtpServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SmtpServer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<smtp_servers>

=cut

__PACKAGE__->table("smtp_servers");

=head1 ACCESSORS

=head2 id

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
  default_value: 25
  is_nullable: 0

=head2 timeout

  data_type: 'integer'
  default_value: 120
  is_nullable: 0

=head2 ssl_mode

  data_type: 'enum'
  extra: {list => ["disabled","ssl","starttls"]}
  is_nullable: 0

=head2 user_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 debug

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 is_default

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
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
  { data_type => "integer", default_value => 25, is_nullable => 0 },
  "timeout",
  { data_type => "integer", default_value => 120, is_nullable => 0 },
  "ssl_mode",
  {
    data_type => "enum",
    extra => { list => ["disabled", "ssl", "starttls"] },
    is_nullable => 0,
  },
  "user_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "debug",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_default",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 library_smtp_servers

Type: has_many

Related object: L<Koha::Schema::Result::LibrarySmtpServer>

=cut

__PACKAGE__->has_many(
  "library_smtp_servers",
  "Koha::Schema::Result::LibrarySmtpServer",
  { "foreign.smtp_server_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-01-20 18:18:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D+EewRQjaYPN3VEOAt8Tkg

__PACKAGE__->add_columns(
    '+debug'      => { is_boolean => 1 },
    '+is_default' => { is_boolean => 1 },
);

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::SMTP::Servers';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::SMTP::Server';
}

1;
