package Koha::Schema::Result::Serialitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Serialitem

=cut

__PACKAGE__->table("serialitems");

=head1 ACCESSORS

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 serialid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "serialid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->add_unique_constraint("serialitemsidx", ["itemnumber"]);

=head1 RELATIONS

=head2 serialid

Type: belongs_to

Related object: L<Koha::Schema::Result::Serial>

=cut

__PACKAGE__->belongs_to(
  "serialid",
  "Koha::Schema::Result::Serial",
  { serialid => "serialid" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A1aGwJJeHrbyhAAtZkFl7g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
