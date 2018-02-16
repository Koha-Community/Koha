use utf8;
package Koha::Schema::Result::Itemtype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Itemtype

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<itemtypes>

=cut

__PACKAGE__->table("itemtypes");

=head1 ACCESSORS

=head2 itemtype

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'longtext'
  is_nullable: 1

=head2 rentalcharge

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 defaultreplacecost

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 processfee

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 notforloan

  data_type: 'smallint'
  is_nullable: 1

=head2 imageurl

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 summary

  data_type: 'mediumtext'
  is_nullable: 1

=head2 checkinmsg

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 checkinmsgtype

  data_type: 'char'
  default_value: 'message'
  is_nullable: 0
  size: 16

=head2 sip_media_type

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 hideinopac

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 searchcategory

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "itemtype",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
  "rentalcharge",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "defaultreplacecost",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "processfee",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "notforloan",
  { data_type => "smallint", is_nullable => 1 },
  "imageurl",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "summary",
  { data_type => "mediumtext", is_nullable => 1 },
  "checkinmsg",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "checkinmsgtype",
  {
    data_type => "char",
    default_value => "message",
    is_nullable => 0,
    size => 16,
  },
  "sip_media_type",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "hideinopac",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "searchcategory",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</itemtype>

=back

=cut

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

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.itemtype" => "self.itemtype" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cNP7/nYGdVeKZ8L7sp1+FQ

# Use the ItemtypeLocalization view to create the join on localization
our $LANGUAGE;
__PACKAGE__->has_many(
  "localization" => "Koha::Schema::Result::ItemtypeLocalization",
    sub {
        my $args = shift;

        die "no lang specified!" unless $LANGUAGE;

        return ({
            "$args->{self_alias}.itemtype" => { -ident => "$args->{foreign_alias}.code" },
            "$args->{foreign_alias}.lang" => $LANGUAGE,
        });

    }
);

1;
