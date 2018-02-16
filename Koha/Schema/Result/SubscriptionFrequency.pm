use utf8;
package Koha::Schema::Result::SubscriptionFrequency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SubscriptionFrequency

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<subscription_frequencies>

=cut

__PACKAGE__->table("subscription_frequencies");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'mediumtext'
  is_nullable: 0

=head2 displayorder

  data_type: 'integer'
  is_nullable: 1

=head2 unit

  data_type: 'enum'
  extra: {list => ["day","week","month","year"]}
  is_nullable: 1

=head2 unitsperissue

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 issuesperunit

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "displayorder",
  { data_type => "integer", is_nullable => 1 },
  "unit",
  {
    data_type => "enum",
    extra => { list => ["day", "week", "month", "year"] },
    is_nullable => 1,
  },
  "unitsperissue",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "issuesperunit",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
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
  { "foreign.periodicity" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AMA/p9t1S6NmZTAHThLROQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
