use utf8;
package Koha::Schema::Result::AccountDebitTypesBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountDebitTypesBranch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_debit_types_branches>

=cut

__PACKAGE__->table("account_debit_types_branches");

=head1 ACCESSORS

=head2 debit_type_code

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 80

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "debit_type_code",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 80 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 debit_type_code

Type: belongs_to

Related object: L<Koha::Schema::Result::AccountDebitType>

=cut

__PACKAGE__->belongs_to(
  "debit_type_code",
  "Koha::Schema::Result::AccountDebitType",
  { code => "debit_type_code" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2019-10-23 13:48:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3ur56KFASvuQ31JGV6OA2Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
