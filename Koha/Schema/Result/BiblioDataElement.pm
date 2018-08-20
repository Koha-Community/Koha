use utf8;
package Koha::Schema::Result::BiblioDataElement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BiblioDataElement

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblio_data_elements>

=cut

__PACKAGE__->table("biblio_data_elements");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblioitemnumber

  data_type: 'integer'
  is_nullable: 0

=head2 last_mod_time

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=head2 deleted

  data_type: 'tinyint'
  is_nullable: 1

=head2 primary_language

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 3

=head2 languages

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 fiction

  data_type: 'tinyint'
  is_nullable: 1

=head2 musical

  data_type: 'tinyint'
  is_nullable: 1

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 serial

  data_type: 'tinyint'
  is_nullable: 1

=head2 encoding_level

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblioitemnumber",
  { data_type => "integer", is_nullable => 0 },
  "last_mod_time",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
  "deleted",
  { data_type => "tinyint", is_nullable => 1 },
  "primary_language",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
  "languages",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "fiction",
  { data_type => "tinyint", is_nullable => 1 },
  "musical",
  { data_type => "tinyint", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "serial",
  { data_type => "tinyint", is_nullable => 1 },
  "encoding_level",
  { data_type => "varchar", is_nullable => 1, size => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<bibitnoidx>

=over 4

=item * L</biblioitemnumber>

=back

=cut

__PACKAGE__->add_unique_constraint("bibitnoidx", ["biblioitemnumber"]);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:THW8gRBK89fyrBDca5dsUg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
