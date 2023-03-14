use utf8;
package Koha::Schema::Result::ActionLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ActionLog

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<action_logs>

=cut

__PACKAGE__->table("action_logs");

=head1 ACCESSORS

=head2 action_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier for each action

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

the date and time the action took place

=head2 user

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

the staff member who performed the action (borrowers.borrowernumber)

=head2 module

  data_type: 'mediumtext'
  is_nullable: 1

the module this action was taken against

=head2 action

  data_type: 'mediumtext'
  is_nullable: 1

the action (includes things like DELETED, ADDED, MODIFY, etc)

=head2 object

  data_type: 'integer'
  is_nullable: 1

the object that the action was taken against (could be a borrowernumber, itemnumber, etc)

=head2 info

  data_type: 'mediumtext'
  is_nullable: 1

information about the action (usually includes SQL statement)

=head2 interface

  data_type: 'varchar'
  is_nullable: 1
  size: 30

the context this action was taken in

=head2 script

  data_type: 'varchar'
  is_nullable: 1
  size: 255

the name of the cron script that caused this change

=head2 trace

  data_type: 'text'
  is_nullable: 1

An optional stack trace enabled by ActionLogsTraceDepth

=cut

__PACKAGE__->add_columns(
  "action_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "user",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "module",
  { data_type => "mediumtext", is_nullable => 1 },
  "action",
  { data_type => "mediumtext", is_nullable => 1 },
  "object",
  { data_type => "integer", is_nullable => 1 },
  "info",
  { data_type => "mediumtext", is_nullable => 1 },
  "interface",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "script",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "trace",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</action_id>

=back

=cut

__PACKAGE__->set_primary_key("action_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-03-14 11:43:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Pk40bYslXRv5opmzBBVs3w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
