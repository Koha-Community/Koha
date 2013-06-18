package Koha::Schema::Result::AuthorisedValuesBranch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::AuthorisedValuesBranch

=cut

__PACKAGE__->table("authorised_values_branches");

=head1 ACCESSORS

=head2 av_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "av_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
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
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yPaKXjOzZX76bddoMqxKmA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
