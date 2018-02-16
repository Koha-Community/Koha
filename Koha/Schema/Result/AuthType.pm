use utf8;
package Koha::Schema::Result::AuthType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AuthType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<auth_types>

=cut

__PACKAGE__->table("auth_types");

=head1 ACCESSORS

=head2 authtypecode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 authtypetext

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 auth_tag_to_report

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 3

=head2 summary

  data_type: 'longtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "authtypecode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "authtypetext",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "auth_tag_to_report",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
  "summary",
  { data_type => "longtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</authtypecode>

=back

=cut

__PACKAGE__->set_primary_key("authtypecode");

=head1 RELATIONS

=head2 auth_subfield_structures

Type: has_many

Related object: L<Koha::Schema::Result::AuthSubfieldStructure>

=cut

__PACKAGE__->has_many(
  "auth_subfield_structures",
  "Koha::Schema::Result::AuthSubfieldStructure",
  { "foreign.authtypecode" => "self.authtypecode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 auth_tag_structures

Type: has_many

Related object: L<Koha::Schema::Result::AuthTagStructure>

=cut

__PACKAGE__->has_many(
  "auth_tag_structures",
  "Koha::Schema::Result::AuthTagStructure",
  { "foreign.authtypecode" => "self.authtypecode" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:USULz4Y8i0JC73GxcxJ+BA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
