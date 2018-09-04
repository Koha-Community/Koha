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

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 cyclical

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 active

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-10-09 15:50:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lTIDZ+w+46Kniub5Tqpqlg

__PACKAGE__->add_columns(
  '+cyclical' => { is_boolean => 1 },
  '+active' => { is_boolean => 1 }
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
