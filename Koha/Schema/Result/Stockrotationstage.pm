use utf8;
package Koha::Schema::Result::Stockrotationstage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Stockrotationstage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<stockrotationstages>

=cut

__PACKAGE__->table("stockrotationstages");

=head1 ACCESSORS

=head2 stage_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Unique stage ID

=head2 position

  data_type: 'integer'
  is_nullable: 0

The position of this stage within its rota

=head2 rota_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

The rota this stage belongs to

=head2 branchcode_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

Branch this stage relates to

=head2 duration

  data_type: 'integer'
  default_value: 4
  is_nullable: 0

The number of days items should occupy this stage

=cut

__PACKAGE__->add_columns(
  "stage_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "position",
  { data_type => "integer", is_nullable => 0 },
  "rota_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "branchcode_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "duration",
  { data_type => "integer", default_value => 4, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</stage_id>

=back

=cut

__PACKAGE__->set_primary_key("stage_id");

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 rota

Type: belongs_to

Related object: L<Koha::Schema::Result::Stockrotationrota>

=cut

__PACKAGE__->belongs_to(
  "rota",
  "Koha::Schema::Result::Stockrotationrota",
  { rota_id => "rota_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 stockrotationitems

Type: has_many

Related object: L<Koha::Schema::Result::Stockrotationitem>

=cut

__PACKAGE__->has_many(
  "stockrotationitems",
  "Koha::Schema::Result::Stockrotationitem",
  { "foreign.stage_id" => "self.stage_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-04-28 16:41:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0UaeR7k2y+4wucQqavr8JQ

# We use DBIx::Class::Ordered to handle stages manipulation.
__PACKAGE__->load_components(qw( Ordered ));

__PACKAGE__->grouping_column('rota_id'); # Our group_id

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::StockRotationStage';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::StockRotationStages';
}

1;
