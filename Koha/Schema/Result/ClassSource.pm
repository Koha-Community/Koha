package Koha::Schema::Result::ClassSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ClassSource

=cut

__PACKAGE__->table("class_sources");

=head1 ACCESSORS

=head2 cn_source

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'mediumtext'
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
  { data_type => "mediumtext", is_nullable => 1 },
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
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fot5u8I5lS5/W0bHPD0Rpw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
