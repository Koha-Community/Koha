use utf8;
package Koha::Schema::Result::BranchBorrowerCircRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BranchBorrowerCircRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<branch_borrower_circ_rules>

=cut

__PACKAGE__->table("branch_borrower_circ_rules");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 categorycode

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

=head2 max_holds

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "categorycode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "maxissueqty",
  { data_type => "integer", is_nullable => 1 },
  "maxonsiteissueqty",
  { data_type => "integer", is_nullable => 1 },
  "max_holds",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</categorycode>

=item * L</branchcode>

=back

=cut

__PACKAGE__->set_primary_key("categorycode", "branchcode");

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

=head2 categorycode

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "categorycode",
  "Koha::Schema::Result::Category",
  { categorycode => "categorycode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-08-25 15:10:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lgs8B3omV3Au570af/VF2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
