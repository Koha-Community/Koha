package Koha::Schema::Result::AuthType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::AuthType

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

  data_type: 'mediumtext'
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
  { data_type => "mediumtext", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("authtypecode");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:n40JCBQ6mHTaHDRGG8mk2w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
