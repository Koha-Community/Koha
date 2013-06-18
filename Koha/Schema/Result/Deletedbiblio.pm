package Koha::Schema::Result::Deletedbiblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Deletedbiblio

=cut

__PACKAGE__->table("deletedbiblio");

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

  data_type: 'mediumtext'
  is_nullable: 1

=head2 title

  data_type: 'mediumtext'
  is_nullable: 1

=head2 unititle

  data_type: 'mediumtext'
  is_nullable: 1

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 serial

  data_type: 'tinyint'
  is_nullable: 1

=head2 seriestitle

  data_type: 'mediumtext'
  is_nullable: 1

=head2 copyrightdate

  data_type: 'smallint'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 datecreated

  data_type: 'date'
  is_nullable: 0

=head2 abstract

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "frameworkcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
  "author",
  { data_type => "mediumtext", is_nullable => 1 },
  "title",
  { data_type => "mediumtext", is_nullable => 1 },
  "unititle",
  { data_type => "mediumtext", is_nullable => 1 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "serial",
  { data_type => "tinyint", is_nullable => 1 },
  "seriestitle",
  { data_type => "mediumtext", is_nullable => 1 },
  "copyrightdate",
  { data_type => "smallint", is_nullable => 1 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "datecreated",
  { data_type => "date", is_nullable => 0 },
  "abstract",
  { data_type => "mediumtext", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("biblionumber");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NeMRnyT+TXPaypKdluD7BQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
