use utf8;
package Koha::Schema::Result::Virtualshelfcontent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Virtualshelfcontent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<virtualshelfcontents>

=cut

__PACKAGE__->table("virtualshelfcontents");

=head1 ACCESSORS

=head2 shelfnumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

foreign key linking to the virtualshelves table, defines the list that this record has been added to

=head2 biblionumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

foreign key linking to the biblio table, defines the bib record that has been added to the list

=head2 dateadded

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time this bib record was added to the list

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrower number that created this list entry (only the first one is saved: no need for use in/as key)

=cut

__PACKAGE__->add_columns(
  "shelfnumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "biblionumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "dateadded",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "SET NULL",
  },
);

=head2 shelfnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Virtualshelve>

=cut

__PACKAGE__->belongs_to(
  "shelfnumber",
  "Koha::Schema::Result::Virtualshelve",
  { shelfnumber => "shelfnumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-07-20 15:47:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BRP+j1kip95rxOd8H5ootg

#TODO See BZ 14544: Should be resolved by db revision
__PACKAGE__->set_primary_key("shelfnumber","biblionumber");

# You can replace this text with custom content, and it will be preserved on regeneration
1;
