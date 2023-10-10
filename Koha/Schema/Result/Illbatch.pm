use utf8;
package Koha::Schema::Result::Illbatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Illbatch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<illbatches>

=cut

__PACKAGE__->table("illbatches");

=head1 ACCESSORS

=head2 ill_batch_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Batch ID

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

Unique name of batch

=head2 backend

  data_type: 'varchar'
  is_nullable: 0
  size: 20

Name of batch backend

=head2 patron_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

Patron associated with batch

=head2 library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 50

Branch associated with batch

=head2 status_code

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 20

Status of batch

=cut

__PACKAGE__->add_columns(
  "ill_batch_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "backend",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "patron_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 50 },
  "status_code",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ill_batch_id>

=back

=cut

__PACKAGE__->set_primary_key("ill_batch_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<u_illbatches__name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("u_illbatches__name", ["name"]);

=head1 RELATIONS

=head2 illrequests

Type: has_many

Related object: L<Koha::Schema::Result::Illrequest>

=cut

__PACKAGE__->has_many(
  "illrequests",
  "Koha::Schema::Result::Illrequest",
  { "foreign.batch_id" => "self.ill_batch_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "library_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 patron

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "patron",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "patron_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 status_code

Type: belongs_to

Related object: L<Koha::Schema::Result::IllbatchStatus>

=cut

__PACKAGE__->belongs_to(
  "status_code",
  "Koha::Schema::Result::IllbatchStatus",
  { code => "status_code" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-10 18:12:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:81afdstzxyW2hhIx6mu4KA

__PACKAGE__->has_many(
  "requests",
  "Koha::Schema::Result::Illrequest",
  { "foreign.batch_id" => "self.ill_batch_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

sub koha_object_class {
    'Koha::Illbatch';
}

sub koha_objects_class {
    'Koha::Illbatches';
}

1;
