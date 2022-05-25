use utf8;
package Koha::Schema::Result::ErmAgreementPeriod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmAgreementPeriod

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_agreement_periods>

=cut

__PACKAGE__->table("erm_agreement_periods");

=head1 ACCESSORS

=head2 agreement_period_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the agreement

=head2 started_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

start of the agreement period

=head2 ended_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

end of the agreement period

=head2 cancellation_deadline

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Deadline for the cancellation

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

notes about this period

=cut

__PACKAGE__->add_columns(
  "agreement_period_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "started_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "ended_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "cancellation_deadline",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</agreement_period_id>

=back

=cut

__PACKAGE__->set_primary_key("agreement_period_id");

=head1 RELATIONS

=head2 agreement

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->belongs_to(
  "agreement",
  "Koha::Schema::Result::ErmAgreement",
  { agreement_id => "agreement_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-05-25 11:46:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NCQpSw+rp/9B/yOrtLtK6g

sub koha_object_class {
    'Koha::ERM::Agreement::Period';
}
sub koha_objects_class {
    'Koha::ERM::Agreement::Periods';
}

1;
