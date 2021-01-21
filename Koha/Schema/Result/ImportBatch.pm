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

unique identifier and primary key

=head2 matcher_id

  data_type: 'integer'
  is_nullable: 1

the id of the match rule used (matchpoints.matcher_id)

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

number of records in the file

=head2 num_items

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

number of items in the file

=head2 upload_timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time the file was uploaded

=head2 overlay_action

  data_type: 'enum'
  default_value: 'create_new'
  extra: {list => ["replace","create_new","use_template","ignore"]}
  is_nullable: 0

how to handle duplicate records

=head2 nomatch_action

  data_type: 'enum'
  default_value: 'create_new'
  extra: {list => ["create_new","ignore"]}
  is_nullable: 0

how to handle records where no match is found

=head2 item_action

  data_type: 'enum'
  default_value: 'always_add'
  extra: {list => ["always_add","add_only_for_matches","add_only_for_new","ignore","replace"]}
  is_nullable: 0

what to do with item records

=head2 import_status

  data_type: 'enum'
  default_value: 'staging'
  extra: {list => ["staging","staged","importing","imported","reverting","reverted","cleaned"]}
  is_nullable: 0

the status of the imported file

=head2 batch_type

  data_type: 'enum'
  default_value: 'batch'
  extra: {list => ["batch","z3950","webservice"]}
  is_nullable: 0

where this batch has come from

=head2 record_type

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["biblio","auth","holdings"]}
  is_nullable: 0

type of record in the batch

=head2 file_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

the name of the file uploaded

=head2 comments

  data_type: 'longtext'
  is_nullable: 1

any comments added when the file was uploaded

=head2 profile_id

  data_type: 'integer'
  is_foreign_key: 1
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
  "profile_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

=head2 profile

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportBatchProfile>

=cut

__PACKAGE__->belongs_to(
  "profile",
  "Koha::Schema::Result::ImportBatchProfile",
  { id => "profile_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "SET NULL",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+/u1tQQzT5ygzGwVgWxxwg

=head2 koha_object_class

  Koha Object class

=cut

sub koha_object_class {
    'Koha::ImportBatch';
}

=head2 koha_objects_class

  Koha Objects class

=cut

sub koha_objects_class {
    'Koha::ImportBatches';
}

1;
