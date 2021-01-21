use utf8;
package Koha::Schema::Result::Desk;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Desk

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<desks>

=cut

__PACKAGE__->table("desks");

=head1 ACCESSORS

=head2 desk_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier

=head2 desk_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

name of the desk

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

library the desk is located at

=cut

__PACKAGE__->add_columns(
  "desk_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "desk_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</desk_id>

=back

=cut

__PACKAGE__->set_primary_key("desk_id");

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.desk_id" => "self.desk_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7qeCP25arGQpM4xxnTmWbw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
