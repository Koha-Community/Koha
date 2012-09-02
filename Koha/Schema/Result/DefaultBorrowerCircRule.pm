package Koha::Schema::Result::DefaultBorrowerCircRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::DefaultBorrowerCircRule

=cut

__PACKAGE__->table("default_borrower_circ_rules");

=head1 ACCESSORS

=head2 categorycode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 maxissueqty

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "categorycode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "maxissueqty",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("categorycode");

=head1 RELATIONS

=head2 categorycode

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "categorycode",
  "Koha::Schema::Result::Category",
  { categorycode => "categorycode" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z6tiOK5+uLufdewEsUrAEQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
