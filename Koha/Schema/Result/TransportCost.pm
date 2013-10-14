use utf8;
package Koha::Schema::Result::TransportCost;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::TransportCost

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<transport_cost>

=cut

__PACKAGE__->table("transport_cost");

=head1 ACCESSORS

=head2 frombranch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 tobranch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 cost

  data_type: 'decimal'
  is_nullable: 0
  size: [6,2]

=head2 disable_transfer

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "frombranch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "tobranch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "cost",
  { data_type => "decimal", is_nullable => 0, size => [6, 2] },
  "disable_transfer",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</frombranch>

=item * L</tobranch>

=back

=cut

__PACKAGE__->set_primary_key("frombranch", "tobranch");

=head1 RELATIONS

=head2 frombranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "frombranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "frombranch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tobranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "tobranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "tobranch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gMs7dT/xK4ClGqQEHI7HOQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
