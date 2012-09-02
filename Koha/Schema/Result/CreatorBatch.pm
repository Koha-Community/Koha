package Koha::Schema::Result::CreatorBatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::CreatorBatch

=cut

__PACKAGE__->table("creator_batches");

=head1 ACCESSORS

=head2 label_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 batch_id

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 item_number

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 borrower_number

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 branch_code

  data_type: 'varchar'
  default_value: 'NB'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 creator

  data_type: 'char'
  default_value: 'Labels'
  is_nullable: 0
  size: 15

=cut

__PACKAGE__->add_columns(
  "label_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "batch_id",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "item_number",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "borrower_number",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "branch_code",
  {
    data_type => "varchar",
    default_value => "NB",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "creator",
  {
    data_type => "char",
    default_value => "Labels",
    is_nullable => 0,
    size => 15,
  },
);
__PACKAGE__->set_primary_key("label_id");

=head1 RELATIONS

=head2 borrower_number

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrower_number",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrower_number" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 branch_code

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branch_code",
  "Koha::Schema::Result::Branch",
  { branchcode => "branch_code" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 item_number

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item_number",
  "Koha::Schema::Result::Item",
  { itemnumber => "item_number" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ei9dbdCUspCrRrhIBHQG6w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
