use utf8;
package Koha::Schema::Result::CashRegister;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::CashRegister

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<cash_registers>

=cut

__PACKAGE__->table("cash_registers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 24

=head2 description

  data_type: 'longtext'
  is_nullable: 0

=head2 branch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 branch_default

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 starting_float

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 archived

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 24 },
  "description",
  { data_type => "longtext", is_nullable => 0 },
  "branch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "branch_default",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "starting_float",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "archived",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=item * L</branch>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name", "branch"]);

=head1 RELATIONS

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.register_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 branch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branch",
  "Koha::Schema::Result::Branch",
  { branchcode => "branch" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2019-07-23 13:14:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TfGf0U/vWS7IviRlvDdE1w

__PACKAGE__->add_columns(
    '+archived'       => { is_boolean => 1 },
    '+branch_default' => { is_boolean => 1 },
);

sub koha_objects_class {
    'Koha::Cash::Registers';
}

sub koha_object_class {
    'Koha::Cash::Register';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
