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

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 delay1

  data_type: 'integer'
  is_nullable: 1

=head2 letter1

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 debarred1

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 1

=head2 delay2

  data_type: 'integer'
  is_nullable: 1

=head2 debarred2

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 1

=head2 letter2

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 delay3

  data_type: 'integer'
  is_nullable: 1

=head2 letter3

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 debarred3

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-01-06 12:00:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Opfa1YZ3IeQRRbyrbKAkNQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
