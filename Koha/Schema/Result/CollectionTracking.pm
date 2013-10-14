use utf8;
package Koha::Schema::Result::CollectionTracking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CollectionTracking

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<collections_tracking>

=cut

__PACKAGE__->table("collections_tracking");

=head1 ACCESSORS

=head2 ctid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 colid

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

collections.colId

=head2 itemnumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

items.itemnumber

=cut

__PACKAGE__->add_columns(
  "ctid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "colid",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ctid>

=back

=cut

__PACKAGE__->set_primary_key("ctid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:izGaZGUJvwrRTQOCotopUg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
