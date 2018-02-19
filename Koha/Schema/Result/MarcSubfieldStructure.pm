use utf8;
package Koha::Schema::Result::MarcSubfieldStructure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcSubfieldStructure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_subfield_structure>

=cut

__PACKAGE__->table("marc_subfield_structure");

=head1 ACCESSORS

=head2 tagfield

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 3

=head2 tagsubfield

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 1

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

=head2 kohafield

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 tab

  data_type: 'tinyint'
  is_nullable: 1

=head2 authorised_value

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 32

=head2 authtypecode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 value_builder

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 isurl

  data_type: 'tinyint'
  is_nullable: 1

=head2 hidden

  data_type: 'tinyint'
  is_nullable: 1

=head2 frameworkcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 seealso

  data_type: 'varchar'
  is_nullable: 1
  size: 1100

=head2 link

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 defaultvalue

  data_type: 'mediumtext'
  is_nullable: 1

=head2 maxlength

  data_type: 'integer'
  default_value: 9999
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tagfield",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
  "tagsubfield",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 1 },
  "liblibrarian",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "libopac",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "repeatable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "mandatory",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "kohafield",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "tab",
  { data_type => "tinyint", is_nullable => 1 },
  "authorised_value",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 32 },
  "authtypecode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "value_builder",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "isurl",
  { data_type => "tinyint", is_nullable => 1 },
  "hidden",
  { data_type => "tinyint", is_nullable => 1 },
  "frameworkcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
  "seealso",
  { data_type => "varchar", is_nullable => 1, size => 1100 },
  "link",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "defaultvalue",
  { data_type => "mediumtext", is_nullable => 1 },
  "maxlength",
  { data_type => "integer", default_value => 9999, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</frameworkcode>

=item * L</tagfield>

=item * L</tagsubfield>

=back

=cut

__PACKAGE__->set_primary_key("frameworkcode", "tagfield", "tagsubfield");

=head1 RELATIONS

=head2 authorised_value

Type: belongs_to

Related object: L<Koha::Schema::Result::AuthorisedValueCategory>

=cut

__PACKAGE__->belongs_to(
  "authorised_value",
  "Koha::Schema::Result::AuthorisedValueCategory",
  { category_name => "authorised_value" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-02 18:57:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:18iBiNNiwTSYtKk28aoLJg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
