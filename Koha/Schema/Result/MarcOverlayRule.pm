use utf8;
package Koha::Schema::Result::MarcOverlayRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcOverlayRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_overlay_rules>

=cut

__PACKAGE__->table("marc_overlay_rules");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 tag

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 module

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 127

=head2 filter

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 add

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 append

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 remove

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 delete

  accessor: undef
  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "tag",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "module",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 127 },
  "filter",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "add",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "append",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "remove",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "delete",
  {
    accessor      => undef,
    data_type     => "tinyint",
    default_value => 0,
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 module

Type: belongs_to

Related object: L<Koha::Schema::Result::MarcOverlayRulesModule>

=cut

__PACKAGE__->belongs_to(
  "module",
  "Koha::Schema::Result::MarcOverlayRulesModule",
  { name => "module" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-03-26 17:56:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zSQHbrkBihPcEkzjW1M2bg

__PACKAGE__->add_columns(
    '+add'    => { is_boolean => 1 },
    '+append' => { is_boolean => 1 },
    '+remove' => { is_boolean => 1 },
    '+delete' => { is_boolean => 1 }
);

1;
