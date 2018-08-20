use utf8;
package Koha::Schema::Result::FloatingMatrix;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::FloatingMatrix

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<floating_matrix>

=cut

__PACKAGE__->table("floating_matrix");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 from_branch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 to_branch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 floating

  data_type: 'enum'
  default_value: 'ALWAYS'
  extra: {list => ["ALWAYS","POSSIBLE","CONDITIONAL"]}
  is_nullable: 0

=head2 condition_rules

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "from_branch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "to_branch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "floating",
  {
    data_type => "enum",
    default_value => "ALWAYS",
    extra => { list => ["ALWAYS", "POSSIBLE", "CONDITIONAL"] },
    is_nullable => 0,
  },
  "condition_rules",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<floating_matrix_uniq_branches>

=over 4

=item * L</from_branch>

=item * L</to_branch>

=back

=cut

__PACKAGE__->add_unique_constraint("floating_matrix_uniq_branches", ["from_branch", "to_branch"]);

=head1 RELATIONS

=head2 from_branch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "from_branch",
  "Koha::Schema::Result::Branch",
  { branchcode => "from_branch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 to_branch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "to_branch",
  "Koha::Schema::Result::Branch",
  { branchcode => "to_branch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K7S/kEXB+kq4ln2iYmGP9w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
