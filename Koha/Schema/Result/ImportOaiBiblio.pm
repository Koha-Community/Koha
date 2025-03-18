use utf8;
package Koha::Schema::Result::ImportOaiBiblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportOaiBiblio

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_oai_biblios>

=cut

__PACKAGE__->table("import_oai_biblios");

=head1 ACCESSORS

=head2 import_oai_biblio_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

unique identifier assigned to each koha record

=head2 identifier

  data_type: 'varchar'
  is_nullable: 0
  size: 255

OAI record identifier

=head2 repository

  data_type: 'varchar'
  is_nullable: 0
  size: 255

OAI repository

=head2 recordtype

  data_type: 'enum'
  default_value: 'biblio'
  extra: {list => ["authority","biblio"]}
  is_nullable: 0

is the record bibliographic or authority

=head2 datestamp

  data_type: 'varchar'
  is_nullable: 1
  size: 255

OAI set to harvest

=head2 last_modified

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "import_oai_biblio_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "identifier",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "repository",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "recordtype",
  {
    data_type => "enum",
    default_value => "biblio",
    extra => { list => ["authority", "biblio"] },
    is_nullable => 0,
  },
  "datestamp",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "last_modified",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</import_oai_biblio_id>

=back

=cut

__PACKAGE__->set_primary_key("import_oai_biblio_id");

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-07-31 14:51:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:25riMQF65/EoFhTXdZbcBg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Import::OAI::Biblio';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Import::OAI::Biblios';
}

1;
