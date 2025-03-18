use utf8;
package Koha::Schema::Result::City;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::City

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<cities>

=cut

__PACKAGE__->table("cities");

=head1 ACCESSORS

=head2 cityid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier added by Koha

=head2 city_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

name of the city

=head2 city_state

  data_type: 'varchar'
  is_nullable: 1
  size: 100

name of the state/province

=head2 city_country

  data_type: 'varchar'
  is_nullable: 1
  size: 100

name of the country

=head2 city_zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

zip or postal code

=cut

__PACKAGE__->add_columns(
  "cityid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "city_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "city_state",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "city_country",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "city_zipcode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</cityid>

=back

=cut

__PACKAGE__->set_primary_key("cityid");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PF0pi+dNbKvxVDSpvHgB1Q

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Cities';
}

1;
