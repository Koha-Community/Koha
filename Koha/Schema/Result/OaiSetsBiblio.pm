use utf8;
package Koha::Schema::Result::OaiSetsBiblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OaiSetsBiblio

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<oai_sets_biblios>

=cut

__PACKAGE__->table("oai_sets_biblios");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_nullable: 0

=head2 set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_nullable => 0 },
  "set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</biblionumber>

=item * L</set_id>

=back

=cut

__PACKAGE__->set_primary_key("biblionumber", "set_id");

=head1 RELATIONS

=head2 set

Type: belongs_to

Related object: L<Koha::Schema::Result::OaiSet>

=cut

__PACKAGE__->belongs_to(
  "set",
  "Koha::Schema::Result::OaiSet",
  { id => "set_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-07-08 15:06:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oGVUyyyune8FVOj504xizw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
