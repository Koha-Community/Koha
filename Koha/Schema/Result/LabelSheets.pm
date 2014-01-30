use utf8;
package Koha::Schema::Result::LabelSheets;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Notify

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<notifys>

=cut

__PACKAGE__->table("label_sheets");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 author

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 version

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 sheet

  data_type: 'mediumtext'
  default_value: ""
  is_nullable: 0


=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "author",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "version",
  { data_type => "float", is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "sheet",
  { data_type => "mediumtext", default_value => "", is_nullable => 0 },
);

1;