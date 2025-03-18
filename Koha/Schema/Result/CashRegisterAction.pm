use utf8;
package Koha::Schema::Result::CashRegisterAction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CashRegisterAction

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<cash_register_actions>

=cut

__PACKAGE__->table("cash_register_actions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier for each account register action

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 24

action code denoting the type of action recorded (enum),

=head2 register_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

id of cash_register this action belongs to,

=head2 manager_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

staff member performing the action

=head2 amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

amount recorded in action (signed)

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 24 },
  "register_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "manager_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
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

=head2 manager

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "manager",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "manager_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 register

Type: belongs_to

Related object: L<Koha::Schema::Result::CashRegister>

=cut

__PACKAGE__->belongs_to(
  "register",
  "Koha::Schema::Result::CashRegister",
  { id => "register_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fo6979mQEueJrDQw38Bh0w

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Cash::Register::Actions';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Cash::Register::Action';
}

1;
