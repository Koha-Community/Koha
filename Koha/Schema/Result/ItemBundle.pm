use utf8;
package Koha::Schema::Result::ItemBundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemBundle

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_bundles>

=cut

__PACKAGE__->table("item_bundles");

=head1 ACCESSORS

=head2 item

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 host

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "item",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "host",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</host>

=item * L</item>

=back

=cut

__PACKAGE__->set_primary_key("host", "item");

=head1 UNIQUE CONSTRAINTS

=head2 C<item_bundles_uniq_1>

=over 4

=item * L</item>

=back

=cut

__PACKAGE__->add_unique_constraint("item_bundles_uniq_1", ["item"]);

=head1 RELATIONS

=head2 host

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "host",
  "Koha::Schema::Result::Item",
  { itemnumber => "host" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 item

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Koha::Schema::Result::Item",
  { itemnumber => "item" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-13 13:32:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PTF+TxbnnYyFQ0XOAaFDWw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
