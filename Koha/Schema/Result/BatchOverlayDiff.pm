use utf8;
package Koha::Schema::Result::BatchOverlayDiff;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BatchOverlayDiff

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<batch_overlay_diff>

=cut

__PACKAGE__->table("batch_overlay_diff");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 batch_overlay_reports_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=head2 operation

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 ruleName

  accessor: 'rule_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 diff

  data_type: 'longtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "batch_overlay_reports_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
  "operation",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "ruleName",
  {
    accessor => "rule_name",
    data_type => "varchar",
    is_nullable => 1,
    size => 20,
  },
  "diff",
  { data_type => "longtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 batch_overlay_diff_headers

Type: has_many

Related object: L<Koha::Schema::Result::BatchOverlayDiffHeader>

=cut

__PACKAGE__->has_many(
  "batch_overlay_diff_headers",
  "Koha::Schema::Result::BatchOverlayDiffHeader",
  { "foreign.batch_overlay_diff_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 batch_overlay_report

Type: belongs_to

Related object: L<Koha::Schema::Result::BatchOverlayReport>

=cut

__PACKAGE__->belongs_to(
  "batch_overlay_report",
  "Koha::Schema::Result::BatchOverlayReport",
  { id => "batch_overlay_reports_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qCUmvrfTDjqUZricEbIUCg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
