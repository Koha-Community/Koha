use utf8;
package Koha::Schema::Result::AqbooksellerAlias;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqbooksellerAlias

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbookseller_aliases>

=cut

__PACKAGE__->table("aqbookseller_aliases");

=head1 ACCESSORS

=head2 alias_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key and unique identifier assigned by Koha

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the vendor

=head2 alias

  data_type: 'varchar'
  is_nullable: 0
  size: 255

the alias

=cut

__PACKAGE__->add_columns(
  "alias_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "alias",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</alias_id>

=back

=cut

__PACKAGE__->set_primary_key("alias_id");

=head1 RELATIONS

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-20 18:19:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FmrIDHGkX2A+3aFZV2FZCA

sub koha_object_class {
    'Koha::Acquisition::Bookseller::Alias';
}
sub koha_objects_class {
    'Koha::Acquisition::Bookseller::Aliases';
}

1;
