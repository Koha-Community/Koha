use utf8;
package Koha::Schema::Result::SearchField;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SearchField

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<search_field>

=cut

__PACKAGE__->table("search_field");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

the name of the field as it will be stored in the search engine

=head2 label

  data_type: 'varchar'
  is_nullable: 0
  size: 255

the human readable name of the field, for display

=head2 type

  data_type: 'enum'
  extra: {list => ["","string","date","number","boolean","sum","isbn","stdno"]}
  is_nullable: 0

what type of data this holds, relevant when storing it in the search engine

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "label",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "type",
  {
    data_type => "enum",
    extra => {
      list => ["", "string", "date", "number", "boolean", "sum", "isbn", "stdno"],
    },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 search_marc_to_fields

Type: has_many

Related object: L<Koha::Schema::Result::SearchMarcToField>

=cut

__PACKAGE__->has_many(
  "search_marc_to_fields",
  "Koha::Schema::Result::SearchMarcToField",
  { "foreign.search_field_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-05-09 12:50:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NDRiXH19vBOhrMoyJqVTGQ

__PACKAGE__->many_to_many("search_marc_maps", "search_marc_to_fields", "search_marc_map");

1;
