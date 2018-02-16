use utf8;
package Koha::Schema::Result::SearchHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SearchHistory - Opac search history results

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<search_history>

=cut

__PACKAGE__->table("search_history");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 userid

  data_type: 'integer'
  is_nullable: 0

=head2 sessionid

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 query_desc

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 query_cgi

  data_type: 'mediumtext'
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  default_value: 'biblio'
  is_nullable: 0
  size: 16

=head2 total

  data_type: 'integer'
  is_nullable: 0

=head2 time

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "userid",
  { data_type => "integer", is_nullable => 0 },
  "sessionid",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "query_desc",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "query_cgi",
  { data_type => "mediumtext", is_nullable => 0 },
  "type",
  {
    data_type => "varchar",
    default_value => "biblio",
    is_nullable => 0,
    size => 16,
  },
  "total",
  { data_type => "integer", is_nullable => 0 },
  "time",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d+Qf8sL7wLldvw2qPLoBgQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
