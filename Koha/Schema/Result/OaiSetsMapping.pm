use utf8;
package Koha::Schema::Result::OaiSetsMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OaiSetsMapping

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<oai_sets_mappings>

=cut

__PACKAGE__->table("oai_sets_mappings");

=head1 ACCESSORS

=head2 set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 marcfield

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 marcsubfield

  data_type: 'char'
  is_nullable: 0
  size: 1

=head2 operator

  data_type: 'varchar'
  default_value: 'equal'
  is_nullable: 0
  size: 8

=head2 marcvalue

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "marcfield",
  { data_type => "char", is_nullable => 0, size => 3 },
  "marcsubfield",
  { data_type => "char", is_nullable => 0, size => 1 },
  "operator",
  {
    data_type => "varchar",
    default_value => "equal",
    is_nullable => 0,
    size => 8,
  },
  "marcvalue",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 RELATIONS

=head2 set

Type: belongs_to

Related object: L<Koha::Schema::Result::OaiSet>

=cut

__PACKAGE__->belongs_to(
  "set",
  "Koha::Schema::Result::OaiSet",
  { id => "set_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A2fchnI85JftSuruZ1CykQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
