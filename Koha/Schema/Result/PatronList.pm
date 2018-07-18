use utf8;
package Koha::Schema::Result::PatronList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PatronList

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<patron_lists>

=cut

__PACKAGE__->table("patron_lists");

=head1 ACCESSORS

=head2 patron_list_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 owner

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 shared

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "patron_list_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "owner",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "shared",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</patron_list_id>

=back

=cut

__PACKAGE__->set_primary_key("patron_list_id");

=head1 RELATIONS

=head2 owner

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "owner" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 patron_list_patrons

Type: has_many

Related object: L<Koha::Schema::Result::PatronListPatron>

=cut

__PACKAGE__->has_many(
  "patron_list_patrons",
  "Koha::Schema::Result::PatronListPatron",
  { "foreign.patron_list_id" => "self.patron_list_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-07-18 16:54:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ulv0BHLlcWdeLgD6qPxmUQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
