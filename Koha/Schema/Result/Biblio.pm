use utf8;
package Koha::Schema::Result::Biblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Biblio

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblio>

=cut

__PACKAGE__->table("biblio");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 frameworkcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 author

  data_type: 'longtext'
  is_nullable: 1

=head2 title

  data_type: 'longtext'
  is_nullable: 1

=head2 medium

  data_type: 'longtext'
  is_nullable: 1

=head2 subtitle

  data_type: 'longtext'
  is_nullable: 1

=head2 part_number

  data_type: 'longtext'
  is_nullable: 1

=head2 part_name

  data_type: 'longtext'
  is_nullable: 1

=head2 unititle

  data_type: 'longtext'
  is_nullable: 1

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

=head2 serial

  data_type: 'tinyint'
  is_nullable: 1

=head2 seriestitle

  data_type: 'longtext'
  is_nullable: 1

=head2 copyrightdate

  data_type: 'smallint'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 datecreated

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 abstract

  data_type: 'longtext'
  is_nullable: 1

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

=head2 aqorders

Type: has_many

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->has_many(
  "aqorders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 article_requests

Type: has_many

Related object: L<Koha::Schema::Result::ArticleRequest>

=cut

__PACKAGE__->has_many(
  "article_requests",
  "Koha::Schema::Result::ArticleRequest",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biblio_metadatas

Type: has_many

Related object: L<Koha::Schema::Result::BiblioMetadata>

=cut

__PACKAGE__->has_many(
  "biblio_metadatas",
  "Koha::Schema::Result::BiblioMetadata",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 biblioitems

Type: has_many

Related object: L<Koha::Schema::Result::Biblioitem>

=cut

__PACKAGE__->has_many(
  "biblioitems",
  "Koha::Schema::Result::Biblioitem",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 club_holds

Type: has_many

Related object: L<Koha::Schema::Result::ClubHold>

=cut

__PACKAGE__->has_many(
  "club_holds",
  "Koha::Schema::Result::ClubHold",
  { "foreign.biblio_id" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 cover_images

Type: has_many

Related object: L<Koha::Schema::Result::CoverImage>

=cut

__PACKAGE__->has_many(
  "cover_images",
  "Koha::Schema::Result::CoverImage",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hold_fill_targets

Type: has_many

Related object: L<Koha::Schema::Result::HoldFillTarget>

=cut

__PACKAGE__->has_many(
  "hold_fill_targets",
  "Koha::Schema::Result::HoldFillTarget",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 items

Type: has_many

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items",
  "Koha::Schema::Result::Item",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_reserves

Type: has_many

Related object: L<Koha::Schema::Result::OldReserve>

=cut

__PACKAGE__->has_many(
  "old_reserves",
  "Koha::Schema::Result::OldReserve",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ratings

Type: has_many

Related object: L<Koha::Schema::Result::Rating>

=cut

__PACKAGE__->has_many(
  "ratings",
  "Koha::Schema::Result::Rating",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reviews

Type: has_many

Related object: L<Koha::Schema::Result::Review>

=cut

__PACKAGE__->has_many(
  "reviews",
  "Koha::Schema::Result::Review",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 serials

Type: has_many

Related object: L<Koha::Schema::Result::Serial>

=cut

__PACKAGE__->has_many(
  "serials",
  "Koha::Schema::Result::Serial",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subscriptionhistories

Type: has_many

Related object: L<Koha::Schema::Result::Subscriptionhistory>

=cut

__PACKAGE__->has_many(
  "subscriptionhistories",
  "Koha::Schema::Result::Subscriptionhistory",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subscriptions

Type: has_many

Related object: L<Koha::Schema::Result::Subscription>

=cut

__PACKAGE__->has_many(
  "subscriptions",
  "Koha::Schema::Result::Subscription",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 suggestions

Type: has_many

Related object: L<Koha::Schema::Result::Suggestion>

=cut

__PACKAGE__->has_many(
  "suggestions",
  "Koha::Schema::Result::Suggestion",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags_all

Type: has_many

Related object: L<Koha::Schema::Result::TagAll>

=cut

__PACKAGE__->has_many(
  "tags_all",
  "Koha::Schema::Result::TagAll",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags_indexes

Type: has_many

Related object: L<Koha::Schema::Result::TagsIndex>

=cut

__PACKAGE__->has_many(
  "tags_indexes",
  "Koha::Schema::Result::TagsIndex",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 virtualshelfcontents

Type: has_many

Related object: L<Koha::Schema::Result::Virtualshelfcontent>

=cut

__PACKAGE__->has_many(
  "virtualshelfcontents",
  "Koha::Schema::Result::Virtualshelfcontent",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-10-12 09:13:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R4PNOXHa9cRIx/up7HWz4Q


__PACKAGE__->has_one(
  "metadata",
  "Koha::Schema::Result::BiblioMetadata",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "orders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.biblionumber" => "self.biblionumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    "+serial" => { is_boolean => 1 }
);

1;
