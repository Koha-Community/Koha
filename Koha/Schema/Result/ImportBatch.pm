use utf8;
package Koha::Schema::Result::ImportBatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportBatch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_batches>

=cut

__PACKAGE__->table("import_batches");

=head1 ACCESSORS

=head2 import_batch_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 matcher_id

  data_type: 'integer'
  is_nullable: 1

=head2 template_id

  data_type: 'integer'
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 num_records

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 num_items

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 upload_timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 overlay_action

  data_type: 'enum'
  default_value: 'create_new'
  extra: {list => ["replace","create_new","use_template","ignore"]}
  is_nullable: 0

=head2 nomatch_action

  data_type: 'enum'
  default_value: 'create_new'
  extra: {list => ["create_new","ignore"]}
  is_nullable: 0

=head2 item_action

  data_type: 'enum'
  default_value: 'always_add'
  extra: {list => ["always_add","add_only_for_matches","add_only_for_new","ignore","replace"]}
  is_nullable: 0

=head2 import_status

  data_type: 'enum'
  default_value: 'staging'
  extra: {list => ["staging","staged","importing","imported","reverting","reverted","cleaned"]}
  is_nullable: 0

=head2 batch_type

  data_type: 'enum'
  default_value: 'batch'
  extra: {list => ["batch","z3950","webservice"]}
  is_nullable: 0

=head2 record_type

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["biblio","auth","holdings"]}
  is_nullable: 0

=head2 file_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 comments

  data_type: 'longtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "import_batch_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "matcher_id",
  { data_type => "integer", is_nullable => 1 },
  "template_id",
  { data_type => "integer", is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "num_records",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "num_items",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "upload_timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "overlay_action",
  {
    data_type => "enum",
    default_value => "create_new",
    extra => { list => ["replace", "create_new", "use_template", "ignore"] },
    is_nullable => 0,
  },
  "nomatch_action",
  {
    data_type => "enum",
    default_value => "create_new",
    extra => { list => ["create_new", "ignore"] },
    is_nullable => 0,
  },
  "item_action",
  {
    data_type => "enum",
    default_value => "always_add",
    extra => {
      list => [
        "always_add",
        "add_only_for_matches",
        "add_only_for_new",
        "ignore",
        "replace",
      ],
    },
    is_nullable => 0,
  },
  "import_status",
  {
    data_type => "enum",
    default_value => "staging",
    extra => {
      list => [
        "staging",
        "staged",
        "importing",
        "imported",
        "reverting",
        "reverted",
        "cleaned",
      ],
    },
    is_nullable => 0,
  },
  "batch_type",
  {
    data_type => "enum",
    default_value => "batch",
    extra => { list => ["batch", "z3950", "webservice"] },
    is_nullable => 0,
  },
  "record_type",
  {
    data_type => "enum",
    default_value => "biblio",
    extra => { list => ["biblio", "auth", "holdings"] },
    is_nullable => 0,
  },
  "file_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "comments",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</import_batch_id>

=back

=cut

__PACKAGE__->set_primary_key("import_batch_id");

=head1 RELATIONS

=head2 import_records

Type: has_many

Related object: L<Koha::Schema::Result::ImportRecord>

=cut

__PACKAGE__->has_many(
  "import_records",
  "Koha::Schema::Result::ImportRecord",
  { "foreign.import_batch_id" => "self.import_batch_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:41giNJCRD9WXC4IGO/1D3A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
