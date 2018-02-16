use utf8;
package Koha::Schema::Result::Biblioitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Biblioitem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblioitems>

=cut

__PACKAGE__->table("biblioitems");

=head1 ACCESSORS

=head2 biblioitemnumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

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

=head2 isbn

  data_type: 'longtext'
  is_nullable: 1

=head2 issn

  data_type: 'longtext'
  is_nullable: 1

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

=head2 volumedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 volumedesc

  data_type: 'mediumtext'
  is_nullable: 1

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

=head2 pages

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

=head2 size

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 place

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 lccn

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 url

  data_type: 'mediumtext'
  is_nullable: 1

=head2 cn_source

  data_type: 'varchar'
  is_nullable: 1
  size: 10

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

=head2 agerestriction

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 totalissues

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "biblioitemnumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
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
  { data_type => "varchar", is_nullable => 1, size => 25 },
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

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 items

Type: has_many

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items",
  "Koha::Schema::Result::Item",
  { "foreign.biblioitemnumber" => "self.biblioitemnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ogVRTKNaUQSI3BE2xC2lww

__PACKAGE__->belongs_to( biblio => "Koha::Schema::Result::Biblio", "biblionumber" );

1;
