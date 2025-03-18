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
  is_nullable: 0

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
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=head1 UNIQUE CONSTRAINTS

=head2 C<guarantor_guarantee_idx>

=over 4

=item * L</guarantor_id>

=item * L</guarantee_id>

=back

=cut

__PACKAGE__->add_unique_constraint("guarantor_guarantee_idx", ["guarantor_id", "guarantee_id"]);

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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-09-19 18:12:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3/qVK3qiXZPvE2y5D4WaRg

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::Relationships';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::Relationship';
}

1;
