use utf8;
package Koha::Schema::Result::DefaultBranchCircRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::DefaultBranchCircRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<default_branch_circ_rules>

=cut

__PACKAGE__->table("default_branch_circ_rules");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 maxissueqty

  data_type: 'integer'
  is_nullable: 1

=head2 maxonsiteissueqty

  data_type: 'integer'
  is_nullable: 1

=head2 holdallowed

  data_type: 'tinyint'
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
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "maxissueqty",
  { data_type => "integer", is_nullable => 1 },
  "maxonsiteissueqty",
  { data_type => "integer", is_nullable => 1 },
  "holdallowed",
  { data_type => "tinyint", is_nullable => 1 },
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

=item * L</branchcode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode");

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-04-29 10:32:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wnrxD1/tp8X01YHmys02lg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
