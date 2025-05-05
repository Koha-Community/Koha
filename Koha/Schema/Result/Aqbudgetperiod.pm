use utf8;
package Koha::Schema::Result::Aqbudgetperiod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqbudgetperiod

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbudgetperiods>

=cut

__PACKAGE__->table("aqbudgetperiods");

=head1 ACCESSORS

=head2 budget_period_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key and unique number assigned by Koha

=head2 budget_period_startdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

date when the budget starts

=head2 budget_period_enddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

date when the budget ends

=head2 budget_period_active

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

whether this budget is active or not (1 for yes, 0 for no)

=head2 budget_period_description

  data_type: 'longtext'
  is_nullable: 1

description assigned to this budget

=head2 budget_period_total

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

total amount available in this budget

=head2 budget_period_locked

  data_type: 'tinyint'
  is_nullable: 1

whether this budget is locked or not (1 for yes, 0 for no)

=head2 sort1_authcat

  data_type: 'varchar'
  is_nullable: 1
  size: 10

statistical category for this budget

=head2 sort2_authcat

  data_type: 'varchar'
  is_nullable: 1
  size: 10

second statistical category for this budget

=cut

__PACKAGE__->add_columns(
  "budget_period_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "budget_period_startdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "budget_period_enddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "budget_period_active",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "budget_period_description",
  { data_type => "longtext", is_nullable => 1 },
  "budget_period_total",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "budget_period_locked",
  { data_type => "tinyint", is_nullable => 1 },
  "sort1_authcat",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "sort2_authcat",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</budget_period_id>

=back

=cut

__PACKAGE__->set_primary_key("budget_period_id");

=head1 RELATIONS

=head2 aqbudgets

Type: has_many

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->has_many(
  "aqbudgets",
  "Koha::Schema::Result::Aqbudget",
  { "foreign.budget_period_id" => "self.budget_period_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F/ipbU/Wrqy3pDInlmLOTw

__PACKAGE__->add_columns(
    '+budget_period_active' => { is_boolean => 1 },
    '+budget_period_locked' => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Acquisition::Budget';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Acquisition::Budgets';
}

1;
