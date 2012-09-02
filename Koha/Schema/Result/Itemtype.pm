package Koha::Schema::Result::Itemtype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Itemtype

=cut

__PACKAGE__->table("itemtypes");

=head1 ACCESSORS

=head2 itemtype

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 rentalcharge

  data_type: 'double precision'
  is_nullable: 1
  size: [16,4]

=head2 notforloan

  data_type: 'smallint'
  is_nullable: 1

=head2 imageurl

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 summary

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "itemtype",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "rentalcharge",
  { data_type => "double precision", is_nullable => 1, size => [16, 4] },
  "notforloan",
  { data_type => "smallint", is_nullable => 1 },
  "imageurl",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "summary",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("itemtype");

=head1 RELATIONS

=head2 branch_item_rules

Type: has_many

Related object: L<Koha::Schema::Result::BranchItemRule>

=cut

__PACKAGE__->has_many(
  "branch_item_rules",
  "Koha::Schema::Result::BranchItemRule",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 default_branch_item_rule

Type: might_have

Related object: L<Koha::Schema::Result::DefaultBranchItemRule>

=cut

__PACKAGE__->might_have(
  "default_branch_item_rule",
  "Koha::Schema::Result::DefaultBranchItemRule",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U4zQb4FXeB0GE8+Kyp9X1Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
