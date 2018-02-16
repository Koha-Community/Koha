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

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 position

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 altphone

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 fax

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

=head2 orderacquisition

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 claimacquisition

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 claimissues

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 acqprimary

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 serialsprimary

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R2x8Z9Db2oDULEODgLuw8Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
