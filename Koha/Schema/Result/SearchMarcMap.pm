use utf8;
package Koha::Schema::Result::SearchMarcMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SearchMarcMap

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<search_marc_map>

=cut

__PACKAGE__->table("search_marc_map");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 index_name

  data_type: 'enum'
  extra: {list => ["biblios","authorities"]}
  is_nullable: 0

what storage index this map is for

=head2 marc_type

  data_type: 'enum'
  extra: {list => ["marc21","unimarc","normarc"]}
  is_nullable: 0

what MARC type this map is for

=head2 marc_field

  data_type: 'varchar'
  is_nullable: 0
  size: 255

the MARC specifier for this field

=head2 facet

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

true if a facet field should be generated for this

=head2 suggestible

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

true if this field can be used to generate suggestions for browse

=head2 sort

  data_type: 'tinyint'
  is_nullable: 1

true/false creates special sort handling, null doesn't

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "index_name",
  {
    data_type => "enum",
    extra => { list => ["biblios", "authorities"] },
    is_nullable => 0,
  },
  "marc_type",
  {
    data_type => "enum",
    extra => { list => ["marc21", "unimarc", "normarc"] },
    is_nullable => 0,
  },
  "marc_field",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "facet",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "suggestible",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "sort",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<index_name_2>

=over 4

=item * L</index_name>

=item * L</marc_type>

=item * L</marc_field>

=back

=cut

__PACKAGE__->add_unique_constraint("index_name_2", ["index_name", "marc_type", "marc_field"]);

=head1 RELATIONS

=head2 search_marc_to_fields

Type: has_many

Related object: L<Koha::Schema::Result::SearchMarcToField>

=cut

__PACKAGE__->has_many(
  "search_marc_to_fields",
  "Koha::Schema::Result::SearchMarcToField",
  { "foreign.search_marc_map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 search_fields

Type: many_to_many

Composing rels: L</search_marc_to_fields> -> search_field

=cut

__PACKAGE__->many_to_many("search_fields", "search_marc_to_fields", "search_field");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-09-01 16:56:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vo1uboO+iKCunqfpetswDg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
