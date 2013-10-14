use utf8;
package Koha::Schema::Result::AqbudgetsPlanning;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqbudgetsPlanning

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbudgets_planning>

=cut

__PACKAGE__->table("aqbudgets_planning");

=head1 ACCESSORS

=head2 plan_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 budget_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 budget_period_id

  data_type: 'integer'
  is_nullable: 0

=head2 estimated_amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 authcat

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 authvalue

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 display

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "plan_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "budget_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "budget_period_id",
  { data_type => "integer", is_nullable => 0 },
  "estimated_amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "authcat",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "authvalue",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "display",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</plan_id>

=back

=cut

__PACKAGE__->set_primary_key("plan_id");

=head1 RELATIONS

=head2 budget

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "budget",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "budget_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7nhWIqgezc+W8sHqJkXCbQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
