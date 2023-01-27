use utf8;
package Koha::Schema::Result::Overduerule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Overduerule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<overduerules>

=cut

__PACKAGE__->table("overduerules");

=head1 ACCESSORS

=head2 overduerules_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier for the overduerules

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

foreign key from the branches table to define which branch this rule is for (if blank it's all libraries)

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

foreign key from the categories table to define which patron category this rule is for

=head2 delay1

  data_type: 'integer'
  is_nullable: 1

number of days after the item is overdue that the first notice is sent

=head2 letter1

  data_type: 'varchar'
  is_nullable: 1
  size: 20

foreign key from the letter table to define which notice should be sent as the first notice

=head2 debarred1

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 1

is the patron restricted when the first notice is sent (1 for yes, 0 for no)

=head2 delay2

  data_type: 'integer'
  is_nullable: 1

number of days after the item is overdue that the second notice is sent

=head2 debarred2

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 1

is the patron restricted when the second notice is sent (1 for yes, 0 for no)

=head2 letter2

  data_type: 'varchar'
  is_nullable: 1
  size: 20

foreign key from the letter table to define which notice should be sent as the second notice

=head2 delay3

  data_type: 'integer'
  is_nullable: 1

number of days after the item is overdue that the third notice is sent

=head2 letter3

  data_type: 'varchar'
  is_nullable: 1
  size: 20

foreign key from the letter table to define which notice should be sent as the third notice

=head2 debarred3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

is the patron restricted when the third notice is sent (1 for yes, 0 for no)

=cut

__PACKAGE__->add_columns(
  "overduerules_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "categorycode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "delay1",
  { data_type => "integer", is_nullable => 1 },
  "letter1",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "debarred1",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 1 },
  "delay2",
  { data_type => "integer", is_nullable => 1 },
  "debarred2",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 1 },
  "letter2",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "delay3",
  { data_type => "integer", is_nullable => 1 },
  "letter3",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "debarred3",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</overduerules_id>

=back

=cut

__PACKAGE__->set_primary_key("overduerules_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<overduerules_branch_cat>

=over 4

=item * L</branchcode>

=item * L</categorycode>

=back

=cut

__PACKAGE__->add_unique_constraint("overduerules_branch_cat", ["branchcode", "categorycode"]);

=head1 RELATIONS

=head2 overduerules_transport_types

Type: has_many

Related object: L<Koha::Schema::Result::OverduerulesTransportType>

=cut

__PACKAGE__->has_many(
  "overduerules_transport_types",
  "Koha::Schema::Result::OverduerulesTransportType",
  { "foreign.overduerules_id" => "self.overduerules_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pORigxtC5qztZWHI29mZ/g

sub koha_object_class {
    'Koha::OverdueRule';
}
sub koha_objects_class {
    'Koha::OverdueRules';
}

1;
