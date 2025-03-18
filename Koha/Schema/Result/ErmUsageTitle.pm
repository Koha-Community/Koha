use utf8;
package Koha::Schema::Result::ErmUsageTitle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmUsageTitle

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_usage_titles>

=cut

__PACKAGE__->table("erm_usage_titles");

=head1 ACCESSORS

=head2 title_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 title

  data_type: 'mediumtext'
  is_nullable: 1

item title

=head2 usage_data_provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

platform the title is harvested by

=head2 title_doi

  data_type: 'varchar'
  is_nullable: 1
  size: 255

DOI number for the title

=head2 proprietary_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

Proprietary_ID for the title

=head2 platform

  data_type: 'varchar'
  is_nullable: 1
  size: 255

platform for the title

=head2 print_issn

  data_type: 'varchar'
  is_nullable: 1
  size: 255

Print ISSN number for the title

=head2 online_issn

  data_type: 'varchar'
  is_nullable: 1
  size: 255

Online ISSN number for the title

=head2 title_uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

URI number for the title

=head2 publisher

  data_type: 'varchar'
  is_nullable: 1
  size: 255

Publisher for the title

=head2 publisher_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

Publisher ID for the title

=head2 isbn

  data_type: 'varchar'
  is_nullable: 1
  size: 255

ISBN of the title

=cut

__PACKAGE__->add_columns(
  "title_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "mediumtext", is_nullable => 1 },
  "usage_data_provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "title_doi",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "proprietary_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "platform",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "print_issn",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "online_issn",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "title_uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publisher",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publisher_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "isbn",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</title_id>

=back

=cut

__PACKAGE__->set_primary_key("title_id");

=head1 RELATIONS

=head2 erm_usage_muses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageMus>

=cut

__PACKAGE__->has_many(
  "erm_usage_muses",
  "Koha::Schema::Result::ErmUsageMus",
  { "foreign.title_id" => "self.title_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 erm_usage_yuses

Type: has_many

Related object: L<Koha::Schema::Result::ErmUsageYus>

=cut

__PACKAGE__->has_many(
  "erm_usage_yuses",
  "Koha::Schema::Result::ErmUsageYus",
  { "foreign.title_id" => "self.title_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 usage_data_provider

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmUsageDataProvider>

=cut

__PACKAGE__->belongs_to(
  "usage_data_provider",
  "Koha::Schema::Result::ErmUsageDataProvider",
  { erm_usage_data_provider_id => "usage_data_provider_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-24 15:06:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2Y2PxWnMTavZYR0ljgZ1lQ


=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ERM::EUsage::UsageTitle';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ERM::EUsage::UsageTitles';
}

1;
