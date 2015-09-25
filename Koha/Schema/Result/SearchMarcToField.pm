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

=head2 search_marc_map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 search_field_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "search_marc_map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "search_field_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</search_marc_map_id>

=item * L</search_field_id>

=back

=cut

__PACKAGE__->set_primary_key("search_marc_map_id", "search_field_id");

=head1 RELATIONS

=head2 search_field

Type: belongs_to

Related object: L<Koha::Schema::Result::SearchField>

=cut

__PACKAGE__->belongs_to(
  "search_field",
  "Koha::Schema::Result::SearchField",
  { id => "search_field_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-09-25 15:19:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:h9oY2xOGibcnsriEfcFe8A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
