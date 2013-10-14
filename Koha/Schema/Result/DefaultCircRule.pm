use utf8;
package Koha::Schema::Result::DefaultCircRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::DefaultCircRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<default_circ_rules>

=cut

__PACKAGE__->table("default_circ_rules");

=head1 ACCESSORS

=head2 singleton

  data_type: 'enum'
  default_value: 'singleton'
  extra: {list => ["singleton"]}
  is_nullable: 0

=head2 maxissueqty

  data_type: 'integer'
  is_nullable: 1

=head2 holdallowed

  data_type: 'integer'
  is_nullable: 1

=head2 returnbranch

  data_type: 'varchar'
  is_nullable: 1
  size: 15

=cut

__PACKAGE__->add_columns(
  "singleton",
  {
    data_type => "enum",
    default_value => "singleton",
    extra => { list => ["singleton"] },
    is_nullable => 0,
  },
  "maxissueqty",
  { data_type => "integer", is_nullable => 1 },
  "holdallowed",
  { data_type => "integer", is_nullable => 1 },
  "returnbranch",
  { data_type => "varchar", is_nullable => 1, size => 15 },
);

=head1 PRIMARY KEY

=over 4

=item * L</singleton>

=back

=cut

__PACKAGE__->set_primary_key("singleton");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I4hY1uJ+wDoWPIiZj5amVg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
