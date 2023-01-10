use utf8;
package Koha::Schema::Result::AccountDebitType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountDebitType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_debit_types>

=cut

__PACKAGE__->table("account_debit_types");

=head1 ACCESSORS

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 can_be_invoiced

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

boolean flag to denote if this debit type is available for manual invoicing

=head2 can_be_sold

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

boolean flag to denote if this debit type is available at point of sale

=head2 default_amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 is_system

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 archived

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

boolean flag to denote if this till is archived or not

=head2 restricts_checkouts

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

boolean flag to denote if the noissuescharge syspref for this debit type is active

=cut

__PACKAGE__->add_columns(
  "code",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "can_be_invoiced",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "can_be_sold",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "default_amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "is_system",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "archived",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "restricts_checkouts",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

=head1 RELATIONS

=head2 account_debit_types_branches

Type: has_many

Related object: L<Koha::Schema::Result::AccountDebitTypesBranch>

=cut

__PACKAGE__->has_many(
  "account_debit_types_branches",
  "Koha::Schema::Result::AccountDebitTypesBranch",
  { "foreign.debit_type_code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.debit_type_code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-01-10 14:49:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9+mMPMSWcc/PwryYNQ2Jqg

__PACKAGE__->add_columns(
    '+is_system' => { is_boolean => 1 }
);

__PACKAGE__->add_columns(
    "+can_be_sold" => { is_boolean => 1 }
);

__PACKAGE__->add_columns(
    "+can_be_invoiced" => { is_boolean => 1 }
);

sub koha_objects_class {
    'Koha::Account::DebitTypes';
}
sub koha_object_class {
    'Koha::Account::DebitType';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
