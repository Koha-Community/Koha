use utf8;
package Koha::Schema::Result::ClassSplitRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClassSplitRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<class_split_rules>

=cut

__PACKAGE__->table("class_split_rules");

=head1 ACCESSORS

=head2 class_split_rule

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'longtext'
  is_nullable: 1

=head2 split_routine

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 30

=head2 split_regex

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "class_split_rule",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "split_routine",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 30 },
  "split_regex",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</class_split_rule>

=back

=cut

__PACKAGE__->set_primary_key("class_split_rule");

=head1 RELATIONS

=head2 class_sources

Type: has_many

Related object: L<Koha::Schema::Result::ClassSource>

=cut

__PACKAGE__->has_many(
  "class_sources",
  "Koha::Schema::Result::ClassSource",
  { "foreign.class_split_rule" => "self.class_split_rule" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-11-13 15:24:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PkAwS2zW9E20B34bFWtV4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
