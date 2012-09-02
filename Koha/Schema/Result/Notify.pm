package Koha::Schema::Result::Notify;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Notify

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
  is_nullable: 1

=head2 notify_send_date

  data_type: 'date'
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
  { data_type => "date", is_nullable => 1 },
  "notify_send_date",
  { data_type => "date", is_nullable => 1 },
  "notify_level",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "method",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ldEIateKiL5a9392TykxWA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
