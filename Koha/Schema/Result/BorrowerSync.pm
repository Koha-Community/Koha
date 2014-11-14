use utf8;
package Koha::Schema::Result::BorrowerSync;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerSync

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_sync>

=cut

__PACKAGE__->table("borrower_sync");

=head1 ACCESSORS

=head2 borrowersyncid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 synctype

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 sync

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 syncstatus

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 lastsync

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 hashed_pin

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "borrowersyncid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "synctype",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "sync",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "syncstatus",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "lastsync",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "hashed_pin",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrowersyncid>

=back

=cut

__PACKAGE__->set_primary_key("borrowersyncid");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-11-14 09:56:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yQUJdr7d6/xD6RvZCH47Yw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
