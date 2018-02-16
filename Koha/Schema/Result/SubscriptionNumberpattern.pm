use utf8;
package Koha::Schema::Result::SubscriptionNumberpattern;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SubscriptionNumberpattern

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<subscription_numberpatterns>

=cut

__PACKAGE__->table("subscription_numberpatterns");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 label

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 displayorder

  data_type: 'integer'
  is_nullable: 1

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

=head2 numberingmethod

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 label1

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 add1

  data_type: 'integer'
  is_nullable: 1

=head2 every1

  data_type: 'integer'
  is_nullable: 1

=head2 whenmorethan1

  data_type: 'integer'
  is_nullable: 1

=head2 setto1

  data_type: 'integer'
  is_nullable: 1

=head2 numbering1

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 label2

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 add2

  data_type: 'integer'
  is_nullable: 1

=head2 every2

  data_type: 'integer'
  is_nullable: 1

=head2 whenmorethan2

  data_type: 'integer'
  is_nullable: 1

=head2 setto2

  data_type: 'integer'
  is_nullable: 1

=head2 numbering2

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 label3

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 add3

  data_type: 'integer'
  is_nullable: 1

=head2 every3

  data_type: 'integer'
  is_nullable: 1

=head2 whenmorethan3

  data_type: 'integer'
  is_nullable: 1

=head2 setto3

  data_type: 'integer'
  is_nullable: 1

=head2 numbering3

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "label",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "displayorder",
  { data_type => "integer", is_nullable => 1 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "numberingmethod",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "label1",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "add1",
  { data_type => "integer", is_nullable => 1 },
  "every1",
  { data_type => "integer", is_nullable => 1 },
  "whenmorethan1",
  { data_type => "integer", is_nullable => 1 },
  "setto1",
  { data_type => "integer", is_nullable => 1 },
  "numbering1",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "label2",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "add2",
  { data_type => "integer", is_nullable => 1 },
  "every2",
  { data_type => "integer", is_nullable => 1 },
  "whenmorethan2",
  { data_type => "integer", is_nullable => 1 },
  "setto2",
  { data_type => "integer", is_nullable => 1 },
  "numbering2",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "label3",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "add3",
  { data_type => "integer", is_nullable => 1 },
  "every3",
  { data_type => "integer", is_nullable => 1 },
  "whenmorethan3",
  { data_type => "integer", is_nullable => 1 },
  "setto3",
  { data_type => "integer", is_nullable => 1 },
  "numbering3",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 subscriptions

Type: has_many

Related object: L<Koha::Schema::Result::Subscription>

=cut

__PACKAGE__->has_many(
  "subscriptions",
  "Koha::Schema::Result::Subscription",
  { "foreign.numberpattern" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UxpUui+IbCUkKDIJOpYyUA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
