package Koha::Schema::Result::OaiSetsDescription;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::OaiSetsDescription

=cut

__PACKAGE__->table("oai_sets_descriptions");

=head1 ACCESSORS

=head2 set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 RELATIONS

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aOzHC9btK44D6oF9qhpidQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
