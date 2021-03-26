use utf8;
package Koha::Schema::Result::MarcOverlayRulesModule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcOverlayRulesModule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_overlay_rules_modules>

=cut

__PACKAGE__->table("marc_overlay_rules_modules");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 127

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 specificity

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", is_nullable => 0, size => 127 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "specificity",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 UNIQUE CONSTRAINTS

=head2 C<specificity>

=over 4

=item * L</specificity>

=back

=cut

__PACKAGE__->add_unique_constraint("specificity", ["specificity"]);

=head1 RELATIONS

=head2 marc_overlay_rules

Type: has_many

Related object: L<Koha::Schema::Result::MarcOverlayRule>

=cut

__PACKAGE__->has_many(
  "marc_overlay_rules",
  "Koha::Schema::Result::MarcOverlayRule",
  { "foreign.module" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-03-26 17:50:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NcP7xFRa7qXyck6wIQg/YQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
