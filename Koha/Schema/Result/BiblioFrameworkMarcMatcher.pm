use utf8;
package Koha::Schema::Result::BiblioFrameworkMarcMatcher;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BiblioFrameworkMarcMatcher

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<biblio_framework_marc_matcher>

=cut

__PACKAGE__->table("biblio_framework_marc_matcher");

=head1 ACCESSORS

=head2 frameworkcode

  data_type: 'varchar'
  is_nullable: 0
  size: 4

MARC framework code

=head2 marc_matcher_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

MARC matcher id

=head2 forbid_duplicate_creation

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Do not show an option to create a duplicate record when a duplicate is found

=cut

__PACKAGE__->add_columns(
  "frameworkcode",
  { data_type => "varchar", is_nullable => 0, size => 4 },
  "marc_matcher_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "forbid_duplicate_creation",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</frameworkcode>

=back

=cut

__PACKAGE__->set_primary_key("frameworkcode");

=head1 RELATIONS

=head2 marc_matcher

Type: belongs_to

Related object: L<Koha::Schema::Result::MarcMatcher>

=cut

__PACKAGE__->belongs_to(
  "marc_matcher",
  "Koha::Schema::Result::MarcMatcher",
  { matcher_id => "marc_matcher_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-03-24 08:59:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vVdKoIqtbvnSk0EXoQT4iw

__PACKAGE__->add_columns(
  '+forbid_duplicate_creation' => { is_boolean => 1 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
