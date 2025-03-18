use utf8;
package Koha::Schema::Result::AccountOffset;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountOffset

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_offsets>

=cut

__PACKAGE__->table("account_offsets");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier for each offset

=head2 credit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

The id of the accountline the increased the patron's balance

=head2 debit_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

The id of the accountline that decreased the patron's balance

=head2 type

  data_type: 'enum'
  extra: {list => ["CREATE","APPLY","VOID","OVERDUE_INCREASE","OVERDUE_DECREASE"]}
  is_nullable: 0

The type of offset this is

=head2 amount

  data_type: 'decimal'
  is_nullable: 0
  size: [26,6]

The amount of the change

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "credit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "debit_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  {
    data_type => "enum",
    extra => {
      list => [
        "CREATE",
        "APPLY",
        "VOID",
        "OVERDUE_INCREASE",
        "OVERDUE_DECREASE",
      ],
    },
    is_nullable => 0,
  },
  "amount",
  { data_type => "decimal", is_nullable => 0, size => [26, 6] },
  "created_on",
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

=head2 credit

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "credit",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "credit_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 debit

Type: belongs_to

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->belongs_to(
  "debit",
  "Koha::Schema::Result::Accountline",
  { accountlines_id => "debit_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-06-21 15:27:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zCeE/SWvdz898zlfcvfRGg

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Account::Offset';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Account::Offsets';
}

1;
