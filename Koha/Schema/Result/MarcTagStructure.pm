use utf8;
package Koha::Schema::Result::MarcTagStructure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcTagStructure

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_tag_structure>

=cut

__PACKAGE__->table("marc_tag_structure");

=head1 ACCESSORS

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
  size: 10

=head2 ind1_defaultvalue

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 1

=head2 ind2_defaultvalue

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 1

=head2 frameworkcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=cut

__PACKAGE__->add_columns(
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
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "ind1_defaultvalue",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 1 },
  "ind2_defaultvalue",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 1 },
  "frameworkcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
);

=head1 PRIMARY KEY

=over 4

=item * L</frameworkcode>

=item * L</tagfield>

=back

=cut

__PACKAGE__->set_primary_key("frameworkcode", "tagfield");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-04-09 09:07:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6EvGakEpGreV0hom7P6Efg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
