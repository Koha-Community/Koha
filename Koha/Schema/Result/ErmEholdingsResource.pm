use utf8;
package Koha::Schema::Result::ErmEholdingsResource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmEholdingsResource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_eholdings_resources>

=cut

__PACKAGE__->table("erm_eholdings_resources");

=head1 ACCESSORS

=head2 resource_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 title_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 package_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 started_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 ended_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 proxy

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "resource_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "package_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "started_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "ended_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "proxy",
  { data_type => "varchar", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</resource_id>

=back

=cut

__PACKAGE__->set_primary_key("resource_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<erm_eholdings_resources_uniq>

=over 4

=item * L</title_id>

=item * L</package_id>

=back

=cut

__PACKAGE__->add_unique_constraint("erm_eholdings_resources_uniq", ["title_id", "package_id"]);

=head1 RELATIONS

=head2 package

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmEholdingsPackage>

=cut

__PACKAGE__->belongs_to(
  "package",
  "Koha::Schema::Result::ErmEholdingsPackage",
  { package_id => "package_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 title

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmEholdingsTitle>

=cut

__PACKAGE__->belongs_to(
  "title",
  "Koha::Schema::Result::ErmEholdingsTitle",
  { title_id => "title_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-20 08:58:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FQbMPJvUGn+kxlA+C4JvYg

sub koha_objects_class {
    'Koha::ERM::EHoldings::Resources';
}
sub koha_object_class {
    'Koha::ERM::EHoldings::Resource';
}

1;
