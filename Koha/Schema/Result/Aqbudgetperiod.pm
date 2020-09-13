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

=head2 budget_period_startdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 budget_period_enddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 budget_period_active

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 budget_period_description

  data_type: 'longtext'
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2020-09-13 23:03:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0xS/Pc8hoKlNKfW9zDd4Gg

sub koha_object_class {
    'Koha::Acquisition::Budget';
}
sub koha_objects_class {
    'Koha::Acquisition::Budgets';
}

1;
