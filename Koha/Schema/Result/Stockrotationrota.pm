use utf8;
package Koha::Schema::Result::Stockrotationrota;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Stockrotationrota

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<stockrotationrotas>

=cut

__PACKAGE__->table("stockrotationrotas");

=head1 ACCESSORS

=head2 rota_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Stockrotation rota ID

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 100

Title for this rota

=head2 description

  data_type: 'text'
  is_nullable: 0

Description for this rota

=head2 cyclical

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Should items on this rota keep cycling?

=head2 active

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Is this rota currently active?

=cut

__PACKAGE__->add_columns(
  "rota_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "cyclical",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "active",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rota_id>

=back

=cut

__PACKAGE__->set_primary_key("rota_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<stockrotationrotas_title>

=over 4

=item * L</title>

=back

=cut

__PACKAGE__->add_unique_constraint("stockrotationrotas_title", ["title"]);

=head1 RELATIONS

=head2 stockrotationstages

Type: has_many

Related object: L<Koha::Schema::Result::Stockrotationstage>

=cut

__PACKAGE__->has_many(
  "stockrotationstages",
  "Koha::Schema::Result::Stockrotationstage",
  { "foreign.rota_id" => "self.rota_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-04-20 11:37:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9jp+fNV7DMuz5i+eMrt/Cw

__PACKAGE__->add_columns(
  '+cyclical' => { is_boolean => 1 },
  '+active' => { is_boolean => 1 }
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::StockRotationRota';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::StockRotationRotas';
}

1;
