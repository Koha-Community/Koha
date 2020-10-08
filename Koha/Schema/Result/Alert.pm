use utf8;
package Koha::Schema::Result::Alert;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Alert

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<alert>

=cut

__PACKAGE__->table("alert");

=head1 ACCESSORS

=head2 alertid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 externalid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "alertid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "externalid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</alertid>

=back

=cut

__PACKAGE__->set_primary_key("alertid");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-10-08 14:17:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jWeIEKGNHlVEBUGBuUXsug


# You can replace this text with custom content, and it will be preserved on regeneration
1;
