use utf8;
package Koha::Schema::Result::SavedReport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SavedReport

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<saved_reports>

=cut

__PACKAGE__->table("saved_reports");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 report_id

  data_type: 'integer'
  is_nullable: 1

=head2 report

  data_type: 'longtext'
  is_nullable: 1

=head2 date_run

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "report_id",
  { data_type => "integer", is_nullable => 1 },
  "report",
  { data_type => "longtext", is_nullable => 1 },
  "date_run",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wvI6/eIxRIm+WWeDVepQaw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
