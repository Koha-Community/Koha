use utf8;
package Koha::Schema::Result::CheckoutRenewal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CheckoutRenewal

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<checkout_renewals>

=cut

__PACKAGE__->table("checkout_renewals");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 issue_id

  data_type: 'integer'
  is_nullable: 1

the id of the issue this renewal pertains to

=head2 renewer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

the id of the user who processed the renewal

=head2 seen

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

boolean denoting whether the item was present or not

=head2 interface

  data_type: 'varchar'
  is_nullable: 0
  size: 16

the interface this renewal took place on

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

the date and time the renewal took place

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "issue_id",
  { data_type => "integer", is_nullable => 1 },
  "renewer_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "seen",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "interface",
  { data_type => "varchar", is_nullable => 0, size => 16 },
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

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 renewer

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "renewer",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "renewer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-03-11 16:33:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:agLgLnVeKYB5wdWS06xD0A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
