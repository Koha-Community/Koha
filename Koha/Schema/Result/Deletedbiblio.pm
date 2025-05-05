use utf8;
package Koha::Schema::Result::Deletedbiblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Deletedbiblio

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<deletedbiblio>

=cut

__PACKAGE__->table("deletedbiblio");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned to each bibliographic record

=head2 frameworkcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4

foreign key from the biblio_framework table to identify which framework was used in cataloging this record

=head2 author

  data_type: 'longtext'
  is_nullable: 1

statement of responsibility from MARC record (100$a in MARC21)

=head2 title

  data_type: 'longtext'
  is_nullable: 1

title (without the subtitle) from the MARC record (245$a in MARC21)

=head2 medium

  data_type: 'longtext'
  is_nullable: 1

medium from the MARC record (245$h in MARC21)

=head2 subtitle

  data_type: 'longtext'
  is_nullable: 1

remainder of the title from the MARC record (245$b in MARC21)

=head2 part_number

  data_type: 'longtext'
  is_nullable: 1

part number from the MARC record (245$n in MARC21)

=head2 part_name

  data_type: 'longtext'
  is_nullable: 1

part name from the MARC record (245$p in MARC21)

=head2 unititle

  data_type: 'longtext'
  is_nullable: 1

uniform title (without the subtitle) from the MARC record (240$a in MARC21)

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

values from the general notes field in the MARC record (500$a in MARC21) split by bar (|)

=head2 serial

  data_type: 'tinyint'
  is_nullable: 1

Boolean indicating whether biblio is for a serial

=head2 seriestitle

  data_type: 'longtext'
  is_nullable: 1

=head2 copyrightdate

  data_type: 'smallint'
  is_nullable: 1

publication or copyright date from the MARC record

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time this record was last touched

=head2 datecreated

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

the date this record was added to Koha

=head2 abstract

  data_type: 'longtext'
  is_nullable: 1

summary from the MARC record (520$a in MARC21)

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "frameworkcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
  "author",
  { data_type => "longtext", is_nullable => 1 },
  "title",
  { data_type => "longtext", is_nullable => 1 },
  "medium",
  { data_type => "longtext", is_nullable => 1 },
  "subtitle",
  { data_type => "longtext", is_nullable => 1 },
  "part_number",
  { data_type => "longtext", is_nullable => 1 },
  "part_name",
  { data_type => "longtext", is_nullable => 1 },
  "unititle",
  { data_type => "longtext", is_nullable => 1 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
  "serial",
  { data_type => "tinyint", is_nullable => 1 },
  "seriestitle",
  { data_type => "longtext", is_nullable => 1 },
  "copyrightdate",
  { data_type => "smallint", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "datecreated",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "abstract",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</biblionumber>

=back

=cut

__PACKAGE__->set_primary_key("biblionumber");

=head1 RELATIONS

=head2 deletedbiblio_metadatas

Type: has_many

Related object: L<Koha::Schema::Result::DeletedbiblioMetadata>

=cut

__PACKAGE__->has_many(
  "deletedbiblio_metadatas",
  "Koha::Schema::Result::DeletedbiblioMetadata",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-04-28 16:41:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+K3LNX9YRsTWv+TVCEKhSQ

__PACKAGE__->has_many(
    "biblioitem",
    "Koha::Schema::Result::Deletedbiblioitem",
    { "foreign.biblionumber" => "self.biblionumber" },
    { cascade_copy           => 0, cascade_delete => 0 },
);

__PACKAGE__->has_one(
    "metadata",
    "Koha::Schema::Result::DeletedbiblioMetadata",
    { "foreign.biblionumber" => "self.biblionumber" },
    { cascade_copy           => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    '+serial' => { is_boolean => 1 },
);

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Old::Biblios';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Old::Biblio';
}

1;
