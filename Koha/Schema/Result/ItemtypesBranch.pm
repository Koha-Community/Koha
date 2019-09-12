use utf8;
package Koha::Schema::Result::ItemtypesBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemtypesBranch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<itemtypes_branches>

=cut

__PACKAGE__->table("itemtypes_branches");

=head1 ACCESSORS

=head2 itemtype

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "itemtype",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
);

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 itemtype

Type: belongs_to

Related object: L<Koha::Schema::Result::Itemtype>

=cut

__PACKAGE__->belongs_to(
  "itemtype",
  "Koha::Schema::Result::Itemtype",
  { itemtype => "itemtype" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2019-07-04 04:56:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cBTswjKV8VWN1iueB+PygQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
