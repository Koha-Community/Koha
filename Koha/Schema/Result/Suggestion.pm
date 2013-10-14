use utf8;
package Koha::Schema::Result::Suggestion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Suggestion

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<suggestions>

=cut

__PACKAGE__->table("suggestions");

=head1 ACCESSORS

=head2 suggestionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 suggestedby

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 suggesteddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00'
  is_nullable: 0

=head2 managedby

  data_type: 'integer'
  is_nullable: 1

=head2 manageddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 acceptedby

  data_type: 'integer'
  is_nullable: 1

=head2 accepteddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 rejectedby

  data_type: 'integer'
  is_nullable: 1

=head2 rejecteddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 author

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 copyrightdate

  data_type: 'smallint'
  is_nullable: 1

=head2 publishercode

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 volumedesc

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 publicationyear

  data_type: 'smallint'
  default_value: 0
  is_nullable: 1

=head2 place

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 isbn

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 mailoverseeing

  data_type: 'smallint'
  default_value: 0
  is_nullable: 1

=head2 biblionumber

  data_type: 'integer'
  is_nullable: 1

=head2 reason

  data_type: 'text'
  is_nullable: 1

=head2 patronreason

  data_type: 'text'
  is_nullable: 1

=head2 budgetid

  data_type: 'integer'
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 collectiontitle

  data_type: 'text'
  is_nullable: 1

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 quantity

  data_type: 'smallint'
  is_nullable: 1

=head2 currency

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 price

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 total

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=cut

__PACKAGE__->add_columns(
  "suggestionid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "suggestedby",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "suggesteddate",
  {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00",
    is_nullable => 0,
  },
  "managedby",
  { data_type => "integer", is_nullable => 1 },
  "manageddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "acceptedby",
  { data_type => "integer", is_nullable => 1 },
  "accepteddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "rejectedby",
  { data_type => "integer", is_nullable => 1 },
  "rejecteddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "status",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "note",
  { data_type => "mediumtext", is_nullable => 1 },
  "author",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "copyrightdate",
  { data_type => "smallint", is_nullable => 1 },
  "publishercode",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "volumedesc",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publicationyear",
  { data_type => "smallint", default_value => 0, is_nullable => 1 },
  "place",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "isbn",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "mailoverseeing",
  { data_type => "smallint", default_value => 0, is_nullable => 1 },
  "biblionumber",
  { data_type => "integer", is_nullable => 1 },
  "reason",
  { data_type => "text", is_nullable => 1 },
  "patronreason",
  { data_type => "text", is_nullable => 1 },
  "budgetid",
  { data_type => "integer", is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "collectiontitle",
  { data_type => "text", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "quantity",
  { data_type => "smallint", is_nullable => 1 },
  "currency",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "price",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "total",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
);

=head1 PRIMARY KEY

=over 4

=item * L</suggestionid>

=back

=cut

__PACKAGE__->set_primary_key("suggestionid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CQRbWbu5MBouyD67ArSRNw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
