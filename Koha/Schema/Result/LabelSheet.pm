use utf8;
package Koha::Schema::Result::LabelSheet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LabelSheet

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<label_sheets>

=cut

__PACKAGE__->table("label_sheets");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 author

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 version

  data_type: 'float'
  is_nullable: 0
  size: [4,1]

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 sheet

  data_type: 'mediumtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "author",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "version",
  { data_type => "float", is_nullable => 0, size => [4, 1] },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "sheet",
  { data_type => "mediumtext", is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<id_version>

=over 4

=item * L</id>

=item * L</version>

=back

=cut

__PACKAGE__->add_unique_constraint("id_version", ["id", "version"]);

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "author" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2017-06-16 18:11:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yRWL1Gm4v2GPmmvJy5XNuQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
