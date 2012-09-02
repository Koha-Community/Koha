package Koha::Schema::Result::ServicesThrottle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ServicesThrottle

=cut

__PACKAGE__->table("services_throttle");

=head1 ACCESSORS

=head2 service_type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 service_count

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=cut

__PACKAGE__->add_columns(
  "service_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "service_count",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);
__PACKAGE__->set_primary_key("service_type");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7zRTP55443DiLZKCWNjYug


# You can replace this text with custom content, and it will be preserved on regeneration
1;
