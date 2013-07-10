package Koha::Schema::Result::PatronListPatron;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::PatronListPatron

=cut

__PACKAGE__->table("patron_list_patrons");

=head1 ACCESSORS

=head2 patron_list_patron_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 patron_list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "patron_list_patron_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patron_list_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("patron_list_patron_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 patron_list

Type: belongs_to

Related object: L<Koha::Schema::Result::PatronList>

=cut

__PACKAGE__->belongs_to(
  "patron_list",
  "Koha::Schema::Result::PatronList",
  { patron_list_id => "patron_list_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-07-10 10:39:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c+znpWBlv6I+yi1EuGUKrQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
