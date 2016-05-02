use utf8;
package Koha::Schema::Result::BorrowerRelationship;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerRelationship

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_relationships>

=cut

__PACKAGE__->table("borrower_relationships");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 guarantor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 guarantee_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 relationship

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "guarantor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "guarantee_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "relationship",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 guarantee

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "guarantee",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "guarantee_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 guarantor

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "guarantor",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "guarantor_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-07-18 10:52:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R8RThgcrct40Zq0UMW3TWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
