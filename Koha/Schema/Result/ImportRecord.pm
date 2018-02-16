use utf8;
package Koha::Schema::Result::ImportRecord;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportRecord

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_records>

=cut

__PACKAGE__->table("import_records");

=head1 ACCESSORS

=head2 import_record_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 import_batch_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 record_sequence

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 upload_timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 import_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 marc

  data_type: 'longblob'
  is_nullable: 0

=head2 marcxml

  data_type: 'longtext'
  is_nullable: 0

=head2 marcxml_old

  data_type: 'longtext'
  is_nullable: 0

=head2 record_type

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["biblio","auth","holdings"]}
  is_nullable: 0

=head2 overlay_status

  data_type: 'enum'
  default_value: 'no_match'
  extra: {list => ["no_match","auto_match","manual_match","match_applied"]}
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'staged'
  extra: {list => ["error","staged","imported","reverted","items_reverted","ignored"]}
  is_nullable: 0

=head2 import_error

  data_type: 'longtext'
  is_nullable: 1

=head2 encoding

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 z3950random

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=cut

__PACKAGE__->add_columns(
  "import_record_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "import_batch_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "record_sequence",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "upload_timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "import_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "marc",
  { data_type => "longblob", is_nullable => 0 },
  "marcxml",
  { data_type => "longtext", is_nullable => 0 },
  "marcxml_old",
  { data_type => "longtext", is_nullable => 0 },
  "record_type",
  {
    data_type => "enum",
    default_value => "biblio",
    extra => { list => ["biblio", "auth", "holdings"] },
    is_nullable => 0,
  },
  "overlay_status",
  {
    data_type => "enum",
    default_value => "no_match",
    extra => {
      list => ["no_match", "auto_match", "manual_match", "match_applied"],
    },
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    default_value => "staged",
    extra => {
      list => [
        "error",
        "staged",
        "imported",
        "reverted",
        "items_reverted",
        "ignored",
      ],
    },
    is_nullable => 0,
  },
  "import_error",
  { data_type => "longtext", is_nullable => 1 },
  "encoding",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "z3950random",
  { data_type => "varchar", is_nullable => 1, size => 40 },
);

=head1 PRIMARY KEY

=over 4

=item * L</import_record_id>

=back

=cut

__PACKAGE__->set_primary_key("import_record_id");

=head1 RELATIONS

=head2 import_auths

Type: has_many

Related object: L<Koha::Schema::Result::ImportAuth>

=cut

__PACKAGE__->has_many(
  "import_auths",
  "Koha::Schema::Result::ImportAuth",
  { "foreign.import_record_id" => "self.import_record_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 import_batch

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportBatch>

=cut

__PACKAGE__->belongs_to(
  "import_batch",
  "Koha::Schema::Result::ImportBatch",
  { import_batch_id => "import_batch_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 import_biblios

Type: has_many

Related object: L<Koha::Schema::Result::ImportBiblio>

=cut

__PACKAGE__->has_many(
  "import_biblios",
  "Koha::Schema::Result::ImportBiblio",
  { "foreign.import_record_id" => "self.import_record_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 import_items

Type: has_many

Related object: L<Koha::Schema::Result::ImportItem>

=cut

__PACKAGE__->has_many(
  "import_items",
  "Koha::Schema::Result::ImportItem",
  { "foreign.import_record_id" => "self.import_record_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 import_record_matches

Type: has_many

Related object: L<Koha::Schema::Result::ImportRecordMatch>

=cut

__PACKAGE__->has_many(
  "import_record_matches",
  "Koha::Schema::Result::ImportRecordMatch",
  { "foreign.import_record_id" => "self.import_record_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yCx/kRJXjPIB5Uuv40TB7g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
