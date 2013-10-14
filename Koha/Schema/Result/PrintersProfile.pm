use utf8;
package Koha::Schema::Result::PrintersProfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PrintersProfile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<printers_profile>

=cut

__PACKAGE__->table("printers_profile");

=head1 ACCESSORS

=head2 profile_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 printer_name

  data_type: 'varchar'
  default_value: 'Default Printer'
  is_nullable: 0
  size: 40

=head2 template_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 paper_bin

  data_type: 'varchar'
  default_value: 'Bypass'
  is_nullable: 0
  size: 20

=head2 offset_horz

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 offset_vert

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 creep_horz

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 creep_vert

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 units

  data_type: 'char'
  default_value: 'POINT'
  is_nullable: 0
  size: 20

=head2 creator

  data_type: 'char'
  default_value: 'Labels'
  is_nullable: 0
  size: 15

=cut

__PACKAGE__->add_columns(
  "profile_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "printer_name",
  {
    data_type => "varchar",
    default_value => "Default Printer",
    is_nullable => 0,
    size => 40,
  },
  "template_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "paper_bin",
  {
    data_type => "varchar",
    default_value => "Bypass",
    is_nullable => 0,
    size => 20,
  },
  "offset_horz",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "offset_vert",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "creep_horz",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "creep_vert",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "units",
  { data_type => "char", default_value => "POINT", is_nullable => 0, size => 20 },
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

=item * L</profile_id>

=back

=cut

__PACKAGE__->set_primary_key("profile_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<printername>

=over 4

=item * L</printer_name>

=item * L</template_id>

=item * L</paper_bin>

=item * L</creator>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "printername",
  ["printer_name", "template_id", "paper_bin", "creator"],
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GJid4zfVF0MmMnUn3xyVbA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
