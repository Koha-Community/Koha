package Koha::Schema::Result::ActionLogs;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ActionLogs

=cut

__PACKAGE__->table("action_logs");

=head1 ACCESSORS

=head2 action_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 user

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 module

  data_type: 'text'
  is_nullable: 1

=head2 action

  data_type: 'text'
  is_nullable: 1

=head2 object

  data_type: 'integer'
  is_nullable: 1

=head2 info

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "action_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "user",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "module",
  { data_type => "text", is_nullable => 1 },
  "action",
  { data_type => "text", is_nullable => 1 },
  "object",
  { data_type => "integer", is_nullable => 1 },
  "info",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("action_id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9VN0SGNBYM/thO7QzQB4Bg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
