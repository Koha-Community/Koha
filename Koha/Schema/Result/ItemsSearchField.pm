use utf8;
package Koha::Schema::Result::ItemsSearchField;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemsSearchField

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<items_search_fields>

=cut

__PACKAGE__->table("items_search_fields");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 label

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 tagfield

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 tagsubfield

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 authorised_values_category

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "label",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "tagfield",
  { data_type => "char", is_nullable => 0, size => 3 },
  "tagsubfield",
  { data_type => "char", is_nullable => 1, size => 1 },
  "authorised_values_category",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 authorised_values_category

Type: belongs_to

Related object: L<Koha::Schema::Result::AuthorisedValueCategory>

=cut

__PACKAGE__->belongs_to(
  "authorised_values_category",
  "Koha::Schema::Result::AuthorisedValueCategory",
  { category_name => "authorised_values_category" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-10-18 09:44:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZA7MFxE/i3NkcZoxg5mBuQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
