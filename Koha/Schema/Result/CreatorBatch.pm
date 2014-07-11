use utf8;
package Koha::Schema::Result::CreatorBatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CreatorBatch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<creator_batches>

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
  datetime_undef_if_invalid: 1
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
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
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

=head1 PRIMARY KEY

=over 4

=item * L</label_id>

=back

=cut

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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 branch_code

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branch_code",
  "Koha::Schema::Result::Branch",
  { branchcode => "branch_code" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 item_number

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item_number",
  "Koha::Schema::Result::Item",
  { itemnumber => "item_number" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-11 09:26:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x9PaYKzfg8jT6zFP4IwhBA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
