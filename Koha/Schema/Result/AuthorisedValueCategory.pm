use utf8;
package Koha::Schema::Result::AuthorisedValueCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AuthorisedValueCategory

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<authorised_value_categories>

=cut

__PACKAGE__->table("authorised_value_categories");

=head1 ACCESSORS

=head2 category_name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "category_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</category_name>

=back

=cut

__PACKAGE__->set_primary_key("category_name");

=head1 RELATIONS

=head2 items_search_fields

Type: has_many

Related object: L<Koha::Schema::Result::ItemsSearchField>

=cut

__PACKAGE__->has_many(
  "items_search_fields",
  "Koha::Schema::Result::ItemsSearchField",
  { "foreign.authorised_values_category" => "self.category_name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-08-29 11:50:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fF91wGF5/xHvp8JX5fAAtw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
