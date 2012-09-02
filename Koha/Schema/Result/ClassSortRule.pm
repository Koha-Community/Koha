package Koha::Schema::Result::ClassSortRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ClassSortRule

=cut

__PACKAGE__->table("class_sort_rules");

=head1 ACCESSORS

=head2 class_sort_rule

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 sort_routine

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 30

=cut

__PACKAGE__->add_columns(
  "class_sort_rule",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "sort_routine",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 30 },
);
__PACKAGE__->set_primary_key("class_sort_rule");

=head1 RELATIONS

=head2 class_sources

Type: has_many

Related object: L<Koha::Schema::Result::ClassSource>

=cut

__PACKAGE__->has_many(
  "class_sources",
  "Koha::Schema::Result::ClassSource",
  { "foreign.class_sort_rule" => "self.class_sort_rule" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3JLMzBsuge+hUAqcXVtgzQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
