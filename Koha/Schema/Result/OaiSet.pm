use utf8;
package Koha::Schema::Result::OaiSet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OaiSet

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<oai_sets>

=cut

__PACKAGE__->table("oai_sets");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 spec

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "spec",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<spec>

=over 4

=item * L</spec>

=back

=cut

__PACKAGE__->add_unique_constraint("spec", ["spec"]);

=head1 RELATIONS

=head2 oai_sets_biblios

Type: has_many

Related object: L<Koha::Schema::Result::OaiSetsBiblio>

=cut

__PACKAGE__->has_many(
  "oai_sets_biblios",
  "Koha::Schema::Result::OaiSetsBiblio",
  { "foreign.set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 oai_sets_descriptions

Type: has_many

Related object: L<Koha::Schema::Result::OaiSetsDescription>

=cut

__PACKAGE__->has_many(
  "oai_sets_descriptions",
  "Koha::Schema::Result::OaiSetsDescription",
  { "foreign.set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 oai_sets_mappings

Type: has_many

Related object: L<Koha::Schema::Result::OaiSetsMapping>

=cut

__PACKAGE__->has_many(
  "oai_sets_mappings",
  "Koha::Schema::Result::OaiSetsMapping",
  { "foreign.set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biblionumbers

Type: many_to_many

Composing rels: L</oai_sets_biblios> -> biblionumber

=cut

__PACKAGE__->many_to_many("biblionumbers", "oai_sets_biblios", "biblionumber");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3M30E7wFbGbesAfQYyalTw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
