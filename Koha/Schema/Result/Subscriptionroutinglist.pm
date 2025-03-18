use utf8;
package Koha::Schema::Result::Subscriptionroutinglist;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Subscriptionroutinglist

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<subscriptionroutinglist>

=cut

__PACKAGE__->table("subscriptionroutinglist");

=head1 ACCESSORS

=head2 routingid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key from the borrowers table, defines with patron is on the routing list

=head2 ranking

  data_type: 'integer'
  is_nullable: 1

where the patron stands in line to receive the serial

=head2 subscriptionid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key from the subscription table, defines which subscription this routing list is for

=cut

__PACKAGE__->add_columns(
  "routingid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ranking",
  { data_type => "integer", is_nullable => 1 },
  "subscriptionid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</routingid>

=back

=cut

__PACKAGE__->set_primary_key("routingid");

=head1 UNIQUE CONSTRAINTS

=head2 C<subscriptionid>

=over 4

=item * L</subscriptionid>

=item * L</borrowernumber>

=back

=cut

__PACKAGE__->add_unique_constraint("subscriptionid", ["subscriptionid", "borrowernumber"]);

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

=head2 subscriptionid

Type: belongs_to

Related object: L<Koha::Schema::Result::Subscription>

=cut

__PACKAGE__->belongs_to(
  "subscriptionid",
  "Koha::Schema::Result::Subscription",
  { subscriptionid => "subscriptionid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L/6xUg+37bAUntrGWWYlaw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Subscription::Routinglist';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Subscription::Routinglists';
}

1;
