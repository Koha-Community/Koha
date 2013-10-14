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

=head2 limitid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 tobranch

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 frombranch

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
  size: 10

=cut

__PACKAGE__->add_columns(
  "limitid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tobranch",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "frombranch",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "ccode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</limitid>

=back

=cut

__PACKAGE__->set_primary_key("limitid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HN/uEtGTNOewMCqTQZ1Vew


# You can replace this text with custom content, and it will be preserved on regeneration
1;
