package Koha::Schema::Result::PatronList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::PatronList

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

=cut

__PACKAGE__->add_columns(
  "patron_list_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "owner",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("patron_list_id");

=head1 RELATIONS

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

=head2 owner

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "owner" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-07-10 10:39:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XegvNUkfR/cYwxlLLX3h3A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
