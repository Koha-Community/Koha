use utf8;
package Koha::Schema::Result::SearchMarcToField;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SearchMarcToField

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<search_marc_to_field>

=cut

__PACKAGE__->table("search_marc_to_field");

=head1 ACCESSORS

=head2 search

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 filter

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

specify a filter to be applied to field

=head2 search_marc_map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 search_field_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

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
  default_value: 1
  is_nullable: 0

Sort defaults to 1 (Yes) and creates sort fields in the index, 0 (no) will prevent this

=cut

__PACKAGE__->add_columns(
  "search",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "filter",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "search_marc_map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "search_field_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "facet",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "suggestible",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "sort",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</search_marc_map_id>

=item * L</search_field_id>

=item * L</filter>

=back

=cut

__PACKAGE__->set_primary_key("search_marc_map_id", "search_field_id", "filter");

=head1 RELATIONS

=head2 search_field

Type: belongs_to

Related object: L<Koha::Schema::Result::SearchField>

=cut

__PACKAGE__->belongs_to(
  "search_field",
  "Koha::Schema::Result::SearchField",
  { id => "search_field_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 search_marc_map

Type: belongs_to

Related object: L<Koha::Schema::Result::SearchMarcMap>

=cut

__PACKAGE__->belongs_to(
  "search_marc_map",
  "Koha::Schema::Result::SearchMarcMap",
  { id => "search_marc_map_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-24 18:41:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rJQhUx0rIc6RVz4HJ5vy/g

__PACKAGE__->add_columns(
    '+facet'       => { is_boolean => 1 },
    '+search'      => { is_boolean => 1 },
    '+sort'        => { is_boolean => 1 },
    '+suggestible' => { is_boolean => 1 },
);

1;
