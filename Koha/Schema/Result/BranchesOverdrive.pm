use utf8;
package Koha::Schema::Result::BranchesOverdrive;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BranchesOverdrive

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<branches_overdrive>

=cut

__PACKAGE__->table("branches_overdrive");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 authname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "authname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode");

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-10-09 10:38:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fEZWWtF4MRDwupI/27laDw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
