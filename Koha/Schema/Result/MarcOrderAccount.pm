use utf8;
package Koha::Schema::Result::MarcOrderAccount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcOrderAccount

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_order_accounts>

=cut

__PACKAGE__->table("marc_order_accounts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier and primary key

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 250

description of this account

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

vendor id for this account

=head2 budget_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

budget id for this account

=head2 download_directory

  data_type: 'mediumtext'
  is_nullable: 1

download directory for this account

=head2 matcher_id

  data_type: 'integer'
  is_nullable: 1

the id of the match rule used (matchpoints.matcher_id)

=head2 overlay_action

  data_type: 'varchar'
  is_nullable: 1
  size: 50

how to handle duplicate records

=head2 nomatch_action

  data_type: 'varchar'
  is_nullable: 1
  size: 50

how to handle records where no match is found

=head2 item_action

  data_type: 'varchar'
  is_nullable: 1
  size: 50

what to do with item records

=head2 parse_items

  data_type: 'tinyint'
  is_nullable: 1

should items be parsed

=head2 record_type

  data_type: 'varchar'
  is_nullable: 1
  size: 50

type of record in the file

=head2 encoding

  data_type: 'varchar'
  is_nullable: 1
  size: 50

file encoding

=head2 match_field

  data_type: 'varchar'
  is_nullable: 1
  size: 10

the field that a vendor account has been mapped to in a marc record

=head2 match_value

  data_type: 'varchar'
  is_nullable: 1
  size: 50

the value to be matched against the marc record

=head2 basket_name_field

  data_type: 'varchar'
  is_nullable: 1
  size: 10

the field that a vendor can use to include a basket name that will be used to create the basket for the file

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 250 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "budget_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "download_directory",
  { data_type => "mediumtext", is_nullable => 1 },
  "matcher_id",
  { data_type => "integer", is_nullable => 1 },
  "overlay_action",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "nomatch_action",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "item_action",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "parse_items",
  { data_type => "tinyint", is_nullable => 1 },
  "record_type",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "encoding",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "match_field",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "match_value",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "basket_name_field",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 budget

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "budget",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "budget_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-04-24 19:44:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LvRybSXMjycTWsAp2Bd4Dw

__PACKAGE__->add_columns(
    '+parse_items' => { is_boolean => 1 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
