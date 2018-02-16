use utf8;
package Koha::Schema::Result::Collection;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Collection

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<collections>

=cut

__PACKAGE__->table("collections");

=head1 ACCESSORS

=head2 colId

  accessor: 'col_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 colTitle

  accessor: 'col_title'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 colDesc

  accessor: 'col_desc'
  data_type: 'mediumtext'
  is_nullable: 0

=head2 colBranchcode

  accessor: 'col_branchcode'
  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "colId",
  {
    accessor          => "col_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "colTitle",
  {
    accessor => "col_title",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 100,
  },
  "colDesc",
  { accessor => "col_desc", data_type => "mediumtext", is_nullable => 0 },
  "colBranchcode",
  {
    accessor => "col_branchcode",
    data_type => "varchar",
    is_foreign_key => 1,
    is_nullable => 1,
    size => 10,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</colId>

=back

=cut

__PACKAGE__->set_primary_key("colId");

=head1 RELATIONS

=head2 col_branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "col_branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "colBranchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Nx6GPmSO3ckjDmF7dz0DKA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
