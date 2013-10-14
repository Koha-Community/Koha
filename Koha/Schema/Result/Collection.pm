use utf8;
package Koha::Schema::Result::Collection;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Collection

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<collections>

=cut

__PACKAGE__->table("collections");

=head1 ACCESSORS

=head2 colid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 coltitle

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 coldesc

  data_type: 'text'
  is_nullable: 0

=head2 colbranchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 4

branchcode for branch where item should be held.

=cut

__PACKAGE__->add_columns(
  "colid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "coltitle",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "coldesc",
  { data_type => "text", is_nullable => 0 },
  "colbranchcode",
  { data_type => "varchar", is_nullable => 1, size => 4 },
);

=head1 PRIMARY KEY

=over 4

=item * L</colid>

=back

=cut

__PACKAGE__->set_primary_key("colid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KNJIC+I4OdfXBAPM8zOB4A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
