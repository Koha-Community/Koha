use utf8;
package Koha::Schema::Result::AqordersClaim;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqordersClaim

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqorders_claims>

=cut

__PACKAGE__->table("aqorders_claims");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

ID of the claims

=head2 ordernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

order linked to this claim

=head2 claimed_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Date of the claims

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "ordernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "claimed_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 ordernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->belongs_to(
  "ordernumber",
  "Koha::Schema::Result::Aqorder",
  { ordernumber => "ordernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4/GYhhysSbrh67vIq67xZw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Acquisition::Order::Claim';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Acquisition::Order::Claims';
}

1;
