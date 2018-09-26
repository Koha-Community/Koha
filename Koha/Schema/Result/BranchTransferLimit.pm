use utf8;
package Koha::Schema::Result::BranchTransferLimit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BranchTransferLimit

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<branch_transfer_limits>

=cut

__PACKAGE__->table("branch_transfer_limits");

=head1 ACCESSORS

=head2 limitId

  accessor: 'limit_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 toBranch

  accessor: 'to_branch'
  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 fromBranch

  accessor: 'from_branch'
  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 ccode

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "limitId",
  {
    accessor          => "limit_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "toBranch",
  {
    accessor => "to_branch",
    data_type => "varchar",
    is_nullable => 0,
    size => 10,
  },
  "fromBranch",
  {
    accessor => "from_branch",
    data_type => "varchar",
    is_nullable => 0,
    size => 10,
  },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</limitId>

=back

=cut

__PACKAGE__->set_primary_key("limitId");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-09-26 16:15:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wKere4dleMGrs9RO59qx9Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
