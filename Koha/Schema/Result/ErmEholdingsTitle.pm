use utf8;
package Koha::Schema::Result::ErmEholdingsTitle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmEholdingsTitle

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_eholdings_titles>

=cut

__PACKAGE__->table("erm_eholdings_titles");

=head1 ACCESSORS

=head2 title_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 biblio_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 publication_title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 external_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 print_identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 online_identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date_first_issue_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 num_first_vol_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 num_first_issue_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date_last_issue_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 num_last_vol_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 num_last_issue_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 title_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 first_author

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 embargo_info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 coverage_depth

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notes

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 publisher_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 publication_type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 date_monograph_published_print

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date_monograph_published_online

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 monograph_volume

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 monograph_edition

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 first_editor

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 parent_publication_title_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 preceeding_publication_title_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 access_type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "title_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblio_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "publication_title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "external_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "print_identifier",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "online_identifier",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_first_issue_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "num_first_vol_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "num_first_issue_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_last_issue_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "num_last_vol_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "num_last_issue_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "title_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "first_author",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "embargo_info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "coverage_depth",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publisher_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publication_type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "date_monograph_published_print",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_monograph_published_online",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "monograph_volume",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "monograph_edition",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "first_editor",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "parent_publication_title_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "preceeding_publication_title_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "access_type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</title_id>

=back

=cut

__PACKAGE__->set_primary_key("title_id");

=head1 RELATIONS

=head2 biblio

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblio",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblio_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 erm_eholdings_resources

Type: has_many

Related object: L<Koha::Schema::Result::ErmEholdingsResource>

=cut

__PACKAGE__->has_many(
  "erm_eholdings_resources",
  "Koha::Schema::Result::ErmEholdingsResource",
  { "foreign.title_id" => "self.title_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-06-22 11:41:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+DZRDExmVLe+MBtk+TEhJw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
