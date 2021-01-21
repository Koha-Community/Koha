use utf8;
package Koha::Schema::Result::LanguageSubtagRegistry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LanguageSubtagRegistry

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<language_subtag_registry>

=cut

__PACKAGE__->table("language_subtag_registry");

=head1 ACCESSORS

=head2 subtag

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 25

language-script-region-variant-extension-privateuse

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 25

only one of the possible descriptions for ease of reference, see language_descriptions for the complete list

=head2 added

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "subtag",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "added",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M4QL1kgte1o/Wz+XjSduWA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
