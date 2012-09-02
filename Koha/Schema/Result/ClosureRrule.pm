package Koha::Schema::Result::ClosureRrule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ClosureRrule

=cut

__PACKAGE__->table("closure_rrule");

=head1 ACCESSORS

=head2 closureid

  data_type: 'integer'
  is_nullable: 1

=head2 recurrence_start

  data_type: 'datetime'
  is_nullable: 1

=head2 recurrence_end

  data_type: 'datetime'
  is_nullable: 1

=head2 frequency

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 days_interval

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "closureid",
  { data_type => "integer", is_nullable => 1 },
  "recurrence_start",
  { data_type => "datetime", is_nullable => 1 },
  "recurrence_end",
  { data_type => "datetime", is_nullable => 1 },
  "frequency",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "days_interval",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g4CMCw0JgKii7mgfHkqThQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
