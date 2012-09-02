package Koha::Schema::Result::OaiSetsBiblio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::OaiSetsBiblio

=cut

__PACKAGE__->table("oai_sets_biblios");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("biblionumber", "set_id");

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 set

Type: belongs_to

Related object: L<Koha::Schema::Result::OaiSet>

=cut

__PACKAGE__->belongs_to(
  "set",
  "Koha::Schema::Result::OaiSet",
  { id => "set_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UkR8n4x6yZOGCMP10KvnRg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
