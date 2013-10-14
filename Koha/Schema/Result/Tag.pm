use utf8;
package Koha::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Tag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 entry

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 weight

  data_type: 'bigint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "entry",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "weight",
  { data_type => "bigint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</entry>

=back

=cut

__PACKAGE__->set_primary_key("entry");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oXXMdTe9zYBblKs7SE8uPg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
