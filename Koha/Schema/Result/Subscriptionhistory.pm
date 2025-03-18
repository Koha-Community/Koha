use utf8;
package Koha::Schema::Result::Subscriptionhistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Subscriptionhistory

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<subscriptionhistory>

=cut

__PACKAGE__->table("subscriptionhistory");

=head1 ACCESSORS

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 subscriptionid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 histstartdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 histenddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 missinglist

  data_type: 'longtext'
  is_nullable: 0

=head2 recievedlist

  data_type: 'longtext'
  is_nullable: 0

=head2 opacnote

  data_type: 'longtext'
  is_nullable: 1

=head2 librariannote

  data_type: 'longtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "subscriptionid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "histstartdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "histenddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "missinglist",
  { data_type => "longtext", is_nullable => 0 },
  "recievedlist",
  { data_type => "longtext", is_nullable => 0 },
  "opacnote",
  { data_type => "longtext", is_nullable => 1 },
  "librariannote",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</subscriptionid>

=back

=cut

__PACKAGE__->set_primary_key("subscriptionid");

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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2020-04-17 09:15:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bcJbffy74eI1r+e4pImAwQ

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Subscription::History';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Subscription::Histories';
}

1;
