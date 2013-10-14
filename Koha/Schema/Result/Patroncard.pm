use utf8;
package Koha::Schema::Result::Patroncard;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Patroncard

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<patroncards>

=cut

__PACKAGE__->table("patroncards");

=head1 ACCESSORS

=head2 cardid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 batch_id

  data_type: 'varchar'
  default_value: 1
  is_nullable: 0
  size: 10

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cardid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "batch_id",
  { data_type => "varchar", default_value => 1, is_nullable => 0, size => 10 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</cardid>

=back

=cut

__PACKAGE__->set_primary_key("cardid");

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZDpN4iw7+y9YP7Dc+ou8lQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
