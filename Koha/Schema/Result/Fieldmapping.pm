package Koha::Schema::Result::Fieldmapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Fieldmapping

=cut

__PACKAGE__->table("fieldmapping");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 field

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 frameworkcode

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 fieldcode

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 subfieldcode

  data_type: 'char'
  is_nullable: 0
  size: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "field",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "frameworkcode",
  { data_type => "char", default_value => "", is_nullable => 0, size => 4 },
  "fieldcode",
  { data_type => "char", is_nullable => 0, size => 3 },
  "subfieldcode",
  { data_type => "char", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gvtMvCtkyoKYhiEqLmhFEg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
