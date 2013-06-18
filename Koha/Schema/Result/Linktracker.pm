package Koha::Schema::Result::Linktracker;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Linktracker

=cut

__PACKAGE__->table("linktracker");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'integer'
  is_nullable: 1

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 1

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 1

=head2 url

  data_type: 'text'
  is_nullable: 1

=head2 timeclicked

  data_type: 'datetime'
  is_nullable: 1

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
  { data_type => "text", is_nullable => 1 },
  "timeclicked",
  { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6e2s/DzzRjvXXrusUC4TZg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
