use utf8;
package Koha::Schema::Result::CollectionsTracking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CollectionsTracking

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<collections_tracking>

=cut

__PACKAGE__->table("collections_tracking");

=head1 ACCESSORS

=head2 collections_tracking_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 colId

  accessor: 'col_id'
  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

collections.colId

=head2 itemnumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

items.itemnumber

=cut

__PACKAGE__->add_columns(
  "collections_tracking_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "colId",
  {
    accessor       => "col_id",
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "itemnumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</collections_tracking_id>

=back

=cut

__PACKAGE__->set_primary_key("collections_tracking_id");

=head1 RELATIONS

=head2 col

Type: belongs_to

Related object: L<Koha::Schema::Result::Collection>

=cut

__PACKAGE__->belongs_to(
  "col",
  "Koha::Schema::Result::Collection",
  { colId => "colId" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-29 07:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JcoZbVCFzYkwbGjyRlH5rA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
