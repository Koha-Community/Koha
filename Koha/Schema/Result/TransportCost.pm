package Koha::Schema::Result::TransportCost;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::TransportCost

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
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tobranch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "tobranch",
  "Koha::Schema::Result::Branch",
  { branchcode => "tobranch" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xaYbVRwPFyhljmGybBzTqA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
