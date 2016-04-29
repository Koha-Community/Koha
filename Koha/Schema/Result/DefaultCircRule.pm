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

=head2 maxonsiteissueqty

  data_type: 'integer'
  is_nullable: 1

=head2 holdallowed

  data_type: 'integer'
  is_nullable: 1

=head2 hold_fulfillment_policy

  data_type: 'enum'
  default_value: 'any'
  extra: {list => ["any","homebranch","holdingbranch"]}
  is_nullable: 0

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
  "maxonsiteissueqty",
  { data_type => "integer", is_nullable => 1 },
  "holdallowed",
  { data_type => "integer", is_nullable => 1 },
  "hold_fulfillment_policy",
  {
    data_type => "enum",
    default_value => "any",
    extra => { list => ["any", "homebranch", "holdingbranch"] },
    is_nullable => 0,
  },
  "returnbranch",
  { data_type => "varchar", is_nullable => 1, size => 15 },
);

=head1 PRIMARY KEY

=over 4

=item * L</singleton>

=back

=cut

__PACKAGE__->set_primary_key("singleton");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-04-29 10:32:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fqBrj0c9h9c0eBlC0kG51w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
