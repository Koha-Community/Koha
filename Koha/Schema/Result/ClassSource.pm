use utf8;
package Koha::Schema::Result::ClassSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClassSource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<class_sources>

=cut

__PACKAGE__->table("class_sources");

=head1 ACCESSORS

=head2 cn_source

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'longtext'
  is_nullable: 1

=head2 used

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 class_sort_rule

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "cn_source",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "used",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "class_sort_rule",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</cn_source>

=back

=cut

__PACKAGE__->set_primary_key("cn_source");

=head1 RELATIONS

=head2 class_sort_rule

Type: belongs_to

Related object: L<Koha::Schema::Result::ClassSortRule>

=cut

__PACKAGE__->belongs_to(
  "class_sort_rule",
  "Koha::Schema::Result::ClassSortRule",
  { class_sort_rule => "class_sort_rule" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tu9NZrk0s8VBgtc1kNpXgg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
