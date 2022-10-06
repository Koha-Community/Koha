use utf8;
package Koha::Schema::Result::SearchFilter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SearchFilter

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<search_filters>

=cut

__PACKAGE__->table("search_filters");

=head1 ACCESSORS

=head2 search_filter_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

filter name

=head2 query

  data_type: 'mediumtext'
  is_nullable: 1

filter query part

=head2 limits

  data_type: 'mediumtext'
  is_nullable: 1

filter limits part

=head2 opac

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

whether this filter is shown on OPAC

=head2 staff_client

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

whether this filter is shown in staff client

=cut

__PACKAGE__->add_columns(
  "search_filter_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "query",
  { data_type => "mediumtext", is_nullable => 1 },
  "limits",
  { data_type => "mediumtext", is_nullable => 1 },
  "opac",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "staff_client",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</search_filter_id>

=back

=cut

__PACKAGE__->set_primary_key("search_filter_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-06 12:25:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:De9VF9DBMhzsbPIbyFGXlQ

__PACKAGE__->add_columns(
    '+opac'         => { is_boolean => 1 },
    '+staff_client' => { is_boolean => 1 },
);

1;
