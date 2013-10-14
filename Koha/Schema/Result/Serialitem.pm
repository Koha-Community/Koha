use utf8;
package Koha::Schema::Result::Serialitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Serialitem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<serialitems>

=cut

__PACKAGE__->table("serialitems");

=head1 ACCESSORS

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 serialid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "serialid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<serialitemsidx>

=over 4

=item * L</itemnumber>

=back

=cut

__PACKAGE__->add_unique_constraint("serialitemsidx", ["itemnumber"]);

=head1 RELATIONS

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 serialid

Type: belongs_to

Related object: L<Koha::Schema::Result::Serial>

=cut

__PACKAGE__->belongs_to(
  "serialid",
  "Koha::Schema::Result::Serial",
  { serialid => "serialid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JZcKy2QIB2c39vgpntWahQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
