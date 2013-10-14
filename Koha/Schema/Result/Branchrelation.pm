use utf8;
package Koha::Schema::Result::Branchrelation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Branchrelation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<branchrelations>

=cut

__PACKAGE__->table("branchrelations");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "branchcode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "categorycode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=item * L</categorycode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode", "categorycode");

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

Related object: L<Koha::Schema::Result::Branchcategory>

=cut

__PACKAGE__->belongs_to(
  "categorycode",
  "Koha::Schema::Result::Branchcategory",
  { categorycode => "categorycode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lBOq8k+wurbp633kbi8tVg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
