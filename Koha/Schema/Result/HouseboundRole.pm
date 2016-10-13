use utf8;
package Koha::Schema::Result::HouseboundRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::HouseboundRole

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<housebound_role>

=cut

__PACKAGE__->table("housebound_role");

=head1 ACCESSORS

=head2 borrowernumber_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 housebound_chooser

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 housebound_deliverer

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "borrowernumber_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "housebound_chooser",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "housebound_deliverer",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrowernumber_id>

=back

=cut

__PACKAGE__->set_primary_key("borrowernumber_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-10-13 07:29:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oRdlsug404i4vErycF4bgg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
