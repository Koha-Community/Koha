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

borrowernumber link

=head2 housebound_chooser

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

set to 1 to indicate this patron is a housebound chooser volunteer

=head2 housebound_deliverer

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

set to 1 to indicate this patron is a housebound deliverer volunteer

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BocU8VE+5j4lYlxNU6Lofw

__PACKAGE__->add_columns(
    '+housebound_chooser'   => { is_boolean => 1 },
    '+housebound_deliverer' => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::HouseboundRole';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::HouseboundRoles';
}

1;
