use utf8;
package Koha::Schema::Result::ErmCounterLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmCounterLog

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_counter_logs>

=cut

__PACKAGE__->table("erm_counter_logs");

=head1 ACCESSORS

=head2 erm_counter_log_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key to borrowers

=head2 counter_files_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key to erm_counter_files

=head2 importdate

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

counter file import date

=head2 filename

  data_type: 'varchar'
  is_nullable: 1
  size: 80

name of the counter file

=head2 logdetails

  data_type: 'longtext'
  is_nullable: 1

details from the counter log

=cut

__PACKAGE__->add_columns(
  "erm_counter_log_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "counter_files_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "importdate",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "logdetails",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</erm_counter_log_id>

=back

=cut

__PACKAGE__->set_primary_key("erm_counter_log_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 counter_file

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmCounterFile>

=cut

__PACKAGE__->belongs_to(
  "counter_file",
  "Koha::Schema::Result::ErmCounterFile",
  { erm_counter_files_id => "counter_files_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-03-16 17:38:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v22verlpwR3+7qLwsxJjtw


sub koha_object_class {
    'Koha::ERM::CounterLog';
}
sub koha_objects_class {
    'Koha::ERM::CounterLogs';
}
1;
