use utf8;
package Koha::Schema::Result::Stockrotationitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Stockrotationitem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<stockrotationitems>

=cut

__PACKAGE__->table("stockrotationitems");

=head1 ACCESSORS

=head2 itemnumber_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Itemnumber to link to a stage & rota

=head2 stage_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

stage ID to link the item to

=head2 indemand

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Should this item be skipped for rotation?

=head2 fresh

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Flag showing item is only just added to rota

=cut

__PACKAGE__->add_columns(
  "itemnumber_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "stage_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "indemand",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "fresh",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</itemnumber_id>

=back

=cut

__PACKAGE__->set_primary_key("itemnumber_id");

=head1 RELATIONS

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 stage

Type: belongs_to

Related object: L<Koha::Schema::Result::Stockrotationstage>

=cut

__PACKAGE__->belongs_to(
  "stage",
  "Koha::Schema::Result::Stockrotationstage",
  { stage_id => "stage_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k/nuwkR8IxEq2D/L6PxmxA

__PACKAGE__->add_columns(
  '+indemand' => { is_boolean => 1 },
  '+fresh' => { is_boolean => 1 }
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::StockRotationItem';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::StockRotationItems';
}

1;
