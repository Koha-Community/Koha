use utf8;
package Koha::Schema::Result::ElasticsearchMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ElasticsearchMapping

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<elasticsearch_mapping>

=cut

__PACKAGE__->table("elasticsearch_mapping");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 mapping

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 facet

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 marc21

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 unimarc

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 normarc

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "mapping",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "facet",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "marc21",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "unimarc",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "normarc",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-07-01 15:12:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D9WpVp24RV/MGHktgXzdkQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
