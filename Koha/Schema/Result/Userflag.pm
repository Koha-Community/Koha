use utf8;
package Koha::Schema::Result::Userflag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Userflag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<userflags>

=cut

__PACKAGE__->table("userflags");

=head1 ACCESSORS

=head2 bit

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 flag

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 flagdesc

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 defaulton

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "bit",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "flag",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "flagdesc",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "defaulton",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bit>

=back

=cut

__PACKAGE__->set_primary_key("bit");

=head1 RELATIONS

=head2 permissions

Type: has_many

Related object: L<Koha::Schema::Result::Permission>

=cut

__PACKAGE__->has_many(
  "permissions",
  "Koha::Schema::Result::Permission",
  { "foreign.module_bit" => "self.bit" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A4wiP/AM/pdmYrJmuiYIYg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
