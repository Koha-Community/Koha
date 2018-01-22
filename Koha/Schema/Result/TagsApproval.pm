use utf8;
package Koha::Schema::Result::TagsApproval;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::TagsApproval

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tags_approval>

=cut

__PACKAGE__->table("tags_approval");

=head1 ACCESSORS

=head2 term

  data_type: 'varchar'
  is_nullable: 0
  size: 191

=head2 approved

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 date_approved

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 approved_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 weight_total

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "term",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "approved",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "date_approved",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "approved_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "weight_total",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</term>

=back

=cut

__PACKAGE__->set_primary_key("term");

=head1 RELATIONS

=head2 approved_by

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "approved_by",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "approved_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 tags_indexes

Type: has_many

Related object: L<Koha::Schema::Result::TagsIndex>

=cut

__PACKAGE__->has_many(
  "tags_indexes",
  "Koha::Schema::Result::TagsIndex",
  { "foreign.term" => "self.term" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-01-18 08:31:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4cvTasSpJ2c1vvVVe/R3UQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
