package Koha::Schema::Result::Aqbudgetperiod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Aqbudgetperiod

=cut

__PACKAGE__->table("aqbudgetperiods");

=head1 ACCESSORS

=head2 budget_period_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 budget_period_startdate

  data_type: 'date'
  is_nullable: 0

=head2 budget_period_enddate

  data_type: 'date'
  is_nullable: 0

=head2 budget_period_active

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 budget_period_description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 budget_period_total

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 budget_period_locked

  data_type: 'tinyint'
  is_nullable: 1

=head2 sort1_authcat

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 sort2_authcat

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "budget_period_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "budget_period_startdate",
  { data_type => "date", is_nullable => 0 },
  "budget_period_enddate",
  { data_type => "date", is_nullable => 0 },
  "budget_period_active",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "budget_period_description",
  { data_type => "mediumtext", is_nullable => 1 },
  "budget_period_total",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "budget_period_locked",
  { data_type => "tinyint", is_nullable => 1 },
  "sort1_authcat",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "sort2_authcat",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("budget_period_id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MKnUsWU+v4zWADuLVahIuQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
