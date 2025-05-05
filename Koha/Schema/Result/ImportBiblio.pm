use utf8;
package Koha::Schema::Result::ImportBiblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportBiblio

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_biblios>

=cut

__PACKAGE__->table("import_biblios");

=head1 ACCESSORS

=head2 import_record_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matched_biblionumber

  data_type: 'integer'
  is_nullable: 1

=head2 control_number

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 original_source

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 title

  data_type: 'longtext'
  is_nullable: 1

=head2 author

  data_type: 'longtext'
  is_nullable: 1

=head2 isbn

  data_type: 'longtext'
  is_nullable: 1

=head2 issn

  data_type: 'longtext'
  is_nullable: 1

=head2 has_items

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "import_record_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matched_biblionumber",
  { data_type => "integer", is_nullable => 1 },
  "control_number",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "original_source",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "title",
  { data_type => "longtext", is_nullable => 1 },
  "author",
  { data_type => "longtext", is_nullable => 1 },
  "isbn",
  { data_type => "longtext", is_nullable => 1 },
  "issn",
  { data_type => "longtext", is_nullable => 1 },
  "has_items",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</import_record_id>

=back

=cut

__PACKAGE__->set_primary_key("import_record_id");

=head1 RELATIONS

=head2 import_record

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportRecord>

=cut

__PACKAGE__->belongs_to(
  "import_record",
  "Koha::Schema::Result::ImportRecord",
  { import_record_id => "import_record_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-17 11:17:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Oj/1VkjYP538OlNeu41mqA

__PACKAGE__->add_columns(
    '+has_items' => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Import::Record::Biblio';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Import::Record::Biblios';
}

1;
