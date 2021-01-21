use utf8;
package Koha::Schema::Result::LanguageScriptBidi;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LanguageScriptBidi

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<language_script_bidi>

=cut

__PACKAGE__->table("language_script_bidi");

=head1 ACCESSORS

=head2 rfc4646_subtag

  data_type: 'varchar'
  is_nullable: 1
  size: 25

script subtag, Arab, Hebr, etc.

=head2 bidi

  data_type: 'varchar'
  is_nullable: 1
  size: 3

rtl ltr

=cut

__PACKAGE__->add_columns(
  "rfc4646_subtag",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "bidi",
  { data_type => "varchar", is_nullable => 1, size => 3 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GSnruAebthrEidJqzPY6Yg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
