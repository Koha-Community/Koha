use utf8;
package Koha::Schema::Result::Deletedbiblioitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Deletedbiblioitem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<deletedbiblioitems>

=cut

__PACKAGE__->table("deletedbiblioitems");

=head1 ACCESSORS

=head2 biblioitemnumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

primary key, unique identifier assigned by Koha

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

foreign key linking this table to the biblio table

=head2 volume

  data_type: 'longtext'
  is_nullable: 1

=head2 number

  data_type: 'longtext'
  is_nullable: 1

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

biblio level item type (MARC21 942$c)

=head2 isbn

  data_type: 'longtext'
  is_nullable: 1

ISBN (MARC21 020$a)

=head2 issn

  data_type: 'longtext'
  is_nullable: 1

ISSN (MARC21 022$a)

=head2 ean

  data_type: 'longtext'
  is_nullable: 1

=head2 publicationyear

  data_type: 'mediumtext'
  is_nullable: 1

=head2 publishercode

  data_type: 'varchar'
  is_nullable: 1
  size: 255

publisher (MARC21 260$b)

=head2 volumedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 volumedesc

  data_type: 'mediumtext'
  is_nullable: 1

volume information (MARC21 362$a)

=head2 collectiontitle

  data_type: 'longtext'
  is_nullable: 1

=head2 collectionissn

  data_type: 'mediumtext'
  is_nullable: 1

=head2 collectionvolume

  data_type: 'longtext'
  is_nullable: 1

=head2 editionstatement

  data_type: 'mediumtext'
  is_nullable: 1

=head2 editionresponsibility

  data_type: 'mediumtext'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 illus

  data_type: 'varchar'
  is_nullable: 1
  size: 255

illustrations (MARC21 300$b)

=head2 pages

  data_type: 'varchar'
  is_nullable: 1
  size: 255

number of pages (MARC21 300$c)

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

=head2 size

  data_type: 'varchar'
  is_nullable: 1
  size: 255

material size (MARC21 300$c)

=head2 place

  data_type: 'varchar'
  is_nullable: 1
  size: 255

publication place (MARC21 260$a)

=head2 lccn

  data_type: 'longtext'
  is_nullable: 1

library of congress control number (MARC21 010$a)

=head2 url

  data_type: 'mediumtext'
  is_nullable: 1

url (MARC21 856$u)

=head2 cn_source

  data_type: 'varchar'
  is_nullable: 1
  size: 10

classification source (MARC21 942$2)

=head2 cn_class

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 cn_item

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 cn_suffix

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 cn_sort

  data_type: 'varchar'
  is_nullable: 1
  size: 255

normalized version of the call number used for sorting

=head2 agerestriction

  data_type: 'varchar'
  is_nullable: 1
  size: 255

target audience/age restriction from the bib record (MARC21 521$a)

=head2 totalissues

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "biblioitemnumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "volume",
  { data_type => "longtext", is_nullable => 1 },
  "number",
  { data_type => "longtext", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "isbn",
  { data_type => "longtext", is_nullable => 1 },
  "issn",
  { data_type => "longtext", is_nullable => 1 },
  "ean",
  { data_type => "longtext", is_nullable => 1 },
  "publicationyear",
  { data_type => "mediumtext", is_nullable => 1 },
  "publishercode",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "volumedate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "volumedesc",
  { data_type => "mediumtext", is_nullable => 1 },
  "collectiontitle",
  { data_type => "longtext", is_nullable => 1 },
  "collectionissn",
  { data_type => "mediumtext", is_nullable => 1 },
  "collectionvolume",
  { data_type => "longtext", is_nullable => 1 },
  "editionstatement",
  { data_type => "mediumtext", is_nullable => 1 },
  "editionresponsibility",
  { data_type => "mediumtext", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "illus",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "pages",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
  "size",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "place",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lccn",
  { data_type => "longtext", is_nullable => 1 },
  "url",
  { data_type => "mediumtext", is_nullable => 1 },
  "cn_source",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "cn_class",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "cn_item",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "cn_suffix",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "cn_sort",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "agerestriction",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "totalissues",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</biblioitemnumber>

=back

=cut

__PACKAGE__->set_primary_key("biblioitemnumber");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-05-03 13:35:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/l/jW3IssAIEgceZPBIEGQ

sub koha_objects_class {
    'Koha::Old::Biblioitems';
}
sub koha_object_class {
    'Koha::Old::Biblioitem';
}

1;
