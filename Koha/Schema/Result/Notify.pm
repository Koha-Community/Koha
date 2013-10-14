use utf8;
package Koha::Schema::Result::Notify;

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

__PACKAGE__->table("notifys");

=head1 ACCESSORS

=head2 notify_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 notify_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 notify_send_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 notify_level

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 method

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "notify_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "notify_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "notify_send_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "notify_level",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "method",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sQc1HF4rGwsMBh6uFNKUnQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
