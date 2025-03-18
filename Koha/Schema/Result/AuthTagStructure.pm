use utf8;
package Koha::Schema::Result::AuthTagStructure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AuthTagStructure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<auth_tag_structure>

=cut

__PACKAGE__->table("auth_tag_structure");

=head1 ACCESSORS

=head2 authtypecode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 tagfield

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 3

=head2 liblibrarian

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 libopac

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 repeatable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 mandatory

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 authorised_value

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "authtypecode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "tagfield",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
  "liblibrarian",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "libopac",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "repeatable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "mandatory",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "authorised_value",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</authtypecode>

=item * L</tagfield>

=back

=cut

__PACKAGE__->set_primary_key("authtypecode", "tagfield");

=head1 RELATIONS

=head2 authtypecode

Type: belongs_to

Related object: L<Koha::Schema::Result::AuthType>

=cut

__PACKAGE__->belongs_to(
  "authtypecode",
  "Koha::Schema::Result::AuthType",
  { authtypecode => "authtypecode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-01-19 06:49:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Nfz88qZS9IgnDbZWcPwlvw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Authority::Tag';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Authority::Tags';
}

1;
