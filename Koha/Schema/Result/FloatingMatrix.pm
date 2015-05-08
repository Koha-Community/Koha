package Koha::Schema::Result::FloatingMatrix;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::FloatingMatrix

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
  size: 20

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
  { data_type => "varchar", is_nullable => 1, size => 20 },
);
__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2015-05-08 18:06:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v6/Qk4/BTfzIuwD0Z2bXmA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
