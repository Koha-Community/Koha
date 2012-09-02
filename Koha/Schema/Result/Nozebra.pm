package Koha::Schema::Result::Nozebra;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Nozebra

=cut

__PACKAGE__->table("nozebra");

=head1 ACCESSORS

=head2 server

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 indexname

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 250

=head2 biblionumbers

  data_type: 'longtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "server",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "indexname",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 250 },
  "biblionumbers",
  { data_type => "longtext", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HEbJLtO1Tpyvy9/w8dnS2w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
