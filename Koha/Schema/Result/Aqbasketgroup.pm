use utf8;
package Koha::Schema::Result::Aqbasketgroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqbasketgroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbasketgroups>

=cut

__PACKAGE__->table("aqbasketgroups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 closed

  data_type: 'tinyint'
  is_nullable: 1

=head2 booksellerid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 deliveryplace

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 freedeliveryplace

  data_type: 'mediumtext'
  is_nullable: 1

=head2 deliverycomment

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 billingplace

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "closed",
  { data_type => "tinyint", is_nullable => 1 },
  "booksellerid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "deliveryplace",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "freedeliveryplace",
  { data_type => "mediumtext", is_nullable => 1 },
  "deliverycomment",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "billingplace",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 aqbaskets

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasket>

=cut

__PACKAGE__->has_many(
  "aqbaskets",
  "Koha::Schema::Result::Aqbasket",
  { "foreign.basketgroupid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 booksellerid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "booksellerid",
  "Koha::Schema::Result::Aqbookseller",
  { id => "booksellerid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9cEWAMwcFKPYPEG1CaaD3w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
