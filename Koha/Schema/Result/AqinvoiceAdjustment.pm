use utf8;
package Koha::Schema::Result::AqinvoiceAdjustment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqinvoiceAdjustment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqinvoice_adjustments>

=cut

__PACKAGE__->table("aqinvoice_adjustments");

=head1 ACCESSORS

=head2 adjustment_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 invoiceid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 adjustment

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 reason

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 budget_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 encumber_open

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "adjustment_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "invoiceid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "adjustment",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "reason",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "note",
  { data_type => "mediumtext", is_nullable => 1 },
  "budget_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "encumber_open",
  { data_type => "smallint", default_value => 1, is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</adjustment_id>

=back

=cut

__PACKAGE__->set_primary_key("adjustment_id");

=head1 RELATIONS

=head2 budget

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "budget",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "budget_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 invoiceid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqinvoice>

=cut

__PACKAGE__->belongs_to(
  "invoiceid",
  "Koha::Schema::Result::Aqinvoice",
  { invoiceid => "invoiceid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-07-19 17:32:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jl0qxkZWVs2D1pi3kaRjpg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
