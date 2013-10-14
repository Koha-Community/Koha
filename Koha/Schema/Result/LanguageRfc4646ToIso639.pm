use utf8;
package Koha::Schema::Result::LanguageRfc4646ToIso639;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LanguageRfc4646ToIso639

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<language_rfc4646_to_iso639>

=cut

__PACKAGE__->table("language_rfc4646_to_iso639");

=head1 ACCESSORS

=head2 rfc4646_subtag

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 iso639_2_code

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rfc4646_subtag",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "iso639_2_code",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:80baGnx1j4ZZjs0Qn5VMsw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
