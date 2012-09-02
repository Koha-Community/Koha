package Koha::Schema::Result::Closure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Closure

=cut

__PACKAGE__->table("closure");

=head1 ACCESSORS

=head2 closureid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 event_start

  data_type: 'datetime'
  is_nullable: 1

=head2 event_end

  data_type: 'datetime'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "closureid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "event_start",
  { data_type => "datetime", is_nullable => 1 },
  "event_end",
  { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("closureid");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yA2qWZ8+Om9n0UAev2wl1Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
