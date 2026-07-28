use utf8;
package Koha::Schema::Result::ReportsBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ReportsBranch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<reports_branches>

=cut

__PACKAGE__->table("reports_branches");

=head1 ACCESSORS

=head2 report_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "report_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
);

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 report

Type: belongs_to

Related object: L<Koha::Schema::Result::SavedSql>

=cut

__PACKAGE__->belongs_to(
  "report",
  "Koha::Schema::Result::SavedSql",
  { id => "report_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-07-28 12:08:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vbql9/bJEGLyaFjEzg1zyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
