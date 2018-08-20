use utf8;
package Koha::Schema::Result::OverdueCalendarException;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OverdueCalendarException

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<overdue_calendar_exceptions>

=cut

__PACKAGE__->table("overdue_calendar_exceptions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 exceptiondate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "exceptiondate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<no_sameday_for_branch>

=over 4

=item * L</branchcode>

=item * L</exceptiondate>

=back

=cut

__PACKAGE__->add_unique_constraint("no_sameday_for_branch", ["branchcode", "exceptiondate"]);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8W7TYgrVj1D5SKDYjfIY9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration


=head1 RELATIONS

=head2 overduecalendarweekday

Type: belongs_to

Related object: L<Koha::Schema::Result::OverdueCalendarWeekday>

=cut

__PACKAGE__->belongs_to(
  "overdue_calendar_weekdays",
  "Koha::Schema::Result::OverdueCalendarWeekday",
  { branchcode => "branchcode" },
);

1;
