use utf8;
package Koha::Schema::Result::Stopword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Stopword

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<stopwords>

=cut

__PACKAGE__->table("stopwords");

=head1 ACCESSORS

=head2 word

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "word",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8cIdWFpf7DlA61On1F7cVg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
