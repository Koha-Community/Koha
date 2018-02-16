use utf8;
package Koha::Schema::Result::Letter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Letter

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<letter>

=cut

__PACKAGE__->table("letter");

=head1 ACCESSORS

=head2 module

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 code

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 is_html

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 200

=head2 content

  data_type: 'mediumtext'
  is_nullable: 1

=head2 message_transport_type

  data_type: 'varchar'
  default_value: 'email'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 lang

  data_type: 'varchar'
  default_value: 'default'
  is_nullable: 0
  size: 25

=cut

__PACKAGE__->add_columns(
  "module",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "is_html",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 200 },
  "content",
  { data_type => "mediumtext", is_nullable => 1 },
  "message_transport_type",
  {
    data_type => "varchar",
    default_value => "email",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 20,
  },
  "lang",
  {
    data_type => "varchar",
    default_value => "default",
    is_nullable => 0,
    size => 25,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</module>

=item * L</code>

=item * L</branchcode>

=item * L</message_transport_type>

=item * L</lang>

=back

=cut

__PACKAGE__->set_primary_key("module", "code", "branchcode", "message_transport_type", "lang");

=head1 RELATIONS

=head2 message_transport_type

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageTransportType>

=cut

__PACKAGE__->belongs_to(
  "message_transport_type",
  "Koha::Schema::Result::MessageTransportType",
  { message_transport_type => "message_transport_type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fOuu1Fj8Uo3114QKS2qLkQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
