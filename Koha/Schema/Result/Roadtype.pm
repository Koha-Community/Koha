use utf8;
package Koha::Schema::Result::Roadtype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Roadtype

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<roadtype>

=cut

__PACKAGE__->table("roadtype");

=head1 ACCESSORS

=head2 roadtypeid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 road_type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "roadtypeid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "road_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</roadtypeid>

=back

=cut

__PACKAGE__->set_primary_key("roadtypeid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5kGeIy5frUgC5wj646dC3g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
