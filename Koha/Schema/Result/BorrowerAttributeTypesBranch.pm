package Koha::Schema::Result::BorrowerAttributeTypesBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::BorrowerAttributeTypesBranch

=cut

__PACKAGE__->table("borrower_attribute_types_branches");

=head1 ACCESSORS

=head2 bat_code

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 b_branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "bat_code",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "b_branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
);

=head1 RELATIONS

=head2 bat_code

Type: belongs_to

Related object: L<Koha::Schema::Result::BorrowerAttributeType>

=cut

__PACKAGE__->belongs_to(
  "bat_code",
  "Koha::Schema::Result::BorrowerAttributeType",
  { code => "bat_code" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 b_branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "b_branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "b_branchcode" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z/zsaV00AbPzi/YfCh+cwA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
