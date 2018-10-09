use utf8;
package Koha::Schema::Result::EdifactEan;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::EdifactEan

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<edifact_ean>

=cut

__PACKAGE__->table("edifact_ean");

=head1 ACCESSORS

=head2 ee_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 ean

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 id_code_qualifier

  data_type: 'varchar'
  default_value: 14
  is_nullable: 0
  size: 3

=cut

__PACKAGE__->add_columns(
  "ee_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "ean",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "id_code_qualifier",
  { data_type => "varchar", default_value => 14, is_nullable => 0, size => 3 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ee_id>

=back

=cut

__PACKAGE__->set_primary_key("ee_id");

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-10-09 11:29:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9CSEvOmfmy52+QAYAgrybA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->belongs_to('branch',
    "Koha::Schema::Result::Branch",
    { 'branchcode' => 'branchcode' },
    {
        is_deferrable => 1,
        join_type => 'LEFT',
        on_delete => 'CASCADE',
        on_update => 'CASCADE',
    },
);

1;
