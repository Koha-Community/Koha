use utf8;
package Koha::Schema::Result::AccountCreditTypesBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountCreditTypesBranch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_credit_types_branches>

=cut

__PACKAGE__->table("account_credit_types_branches");

=head1 ACCESSORS

=head2 credit_type_code

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
  "credit_type_code",
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

=head2 credit_type_code

Type: belongs_to

Related object: L<Koha::Schema::Result::AccountCreditType>

=cut

__PACKAGE__->belongs_to(
  "credit_type_code",
  "Koha::Schema::Result::AccountCreditType",
  { code => "credit_type_code" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2019-10-14 09:59:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1oX/zPeT8gmc3ZwdTiyovA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
