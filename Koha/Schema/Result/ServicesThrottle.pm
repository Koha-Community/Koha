use utf8;
package Koha::Schema::Result::ServicesThrottle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ServicesThrottle

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<services_throttle>

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

=head1 PRIMARY KEY

=over 4

=item * L</service_type>

=back

=cut

__PACKAGE__->set_primary_key("service_type");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XxtEV+cJ5qa/3oCHd2GrSw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
