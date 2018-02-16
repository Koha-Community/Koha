use utf8;
package Koha::Schema::Result::Localization;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Localization

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<localization>

=cut

__PACKAGE__->table("localization");

=head1 ACCESSORS

=head2 localization_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 entity

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 lang

  data_type: 'varchar'
  is_nullable: 0
  size: 25

=head2 translation

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "localization_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "entity",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "lang",
  { data_type => "varchar", is_nullable => 0, size => 25 },
  "translation",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</localization_id>

=back

=cut

__PACKAGE__->set_primary_key("localization_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<entity_code_lang>

=over 4

=item * L</entity>

=item * L</code>

=item * L</lang>

=back

=cut

__PACKAGE__->add_unique_constraint("entity_code_lang", ["entity", "code", "lang"]);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4642LmshpGd3JW7YxM5pIA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
