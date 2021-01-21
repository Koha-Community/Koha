use utf8;
package Koha::Schema::Result::Linktracker;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Linktracker

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<linktracker>

=cut

__PACKAGE__->table("linktracker");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key identifier

=head2 biblionumber

  data_type: 'integer'
  is_nullable: 1

biblionumber of the record the link is from

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 1

itemnumber if applicable that the link was from

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

borrowernumber who clicked the link

=head2 url

  data_type: 'mediumtext'
  is_nullable: 1

the link itself

=head2 timeclicked

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date and time the link was clicked

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_nullable => 1 },
  "itemnumber",
  { data_type => "integer", is_nullable => 1 },
  "borrowernumber",
  { data_type => "integer", is_nullable => 1 },
  "url",
  { data_type => "mediumtext", is_nullable => 1 },
  "timeclicked",
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dNzvrDz4qAO/rvZaYUEjAg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
