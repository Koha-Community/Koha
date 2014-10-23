use utf8;
package Koha::Schema::Result::AuthorisedValuesBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AuthorisedValuesBranch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<authorised_values_branches>

=cut

__PACKAGE__->table("authorised_values_branches");

=head1 ACCESSORS

=head2 av_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "av_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
);

=head1 RELATIONS

=head2 av

Type: belongs_to

Related object: L<Koha::Schema::Result::AuthorisedValue>

=cut

__PACKAGE__->belongs_to(
  "av",
  "Koha::Schema::Result::AuthorisedValue",
  { id => "av_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-10-23 10:48:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cjPAyQSK7F7sEkiWjCUE7Q

__PACKAGE__->set_primary_key(__PACKAGE__->columns);

1;
