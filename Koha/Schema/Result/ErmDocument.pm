use utf8;
package Koha::Schema::Result::ErmDocument;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmDocument

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_documents>

=cut

__PACKAGE__->table("erm_documents");

=head1 ACCESSORS

=head2 document_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

link to the agreement

=head2 license_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

link to the license

=head2 file_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

name of the file

=head2 file_type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

type of the file

=head2 file_description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

description of the file

=head2 file_content

  data_type: 'longblob'
  is_nullable: 1

the content of the file

=head2 uploaded_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

datetime when the file as attached

=head2 physical_location

  data_type: 'varchar'
  is_nullable: 1
  size: 255

physical location of the document

=head2 uri

  data_type: 'varchar'
  is_nullable: 1
  size: 255

URI of the document

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

notes about this relationship

=cut

__PACKAGE__->add_columns(
  "document_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "license_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "file_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "file_type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "file_description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "file_content",
  { data_type => "longblob", is_nullable => 1 },
  "uploaded_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "physical_location",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "uri",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</document_id>

=back

=cut

__PACKAGE__->set_primary_key("document_id");

=head1 RELATIONS

=head2 agreement

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->belongs_to(
  "agreement",
  "Koha::Schema::Result::ErmAgreement",
  { agreement_id => "agreement_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 license

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmLicense>

=cut

__PACKAGE__->belongs_to(
  "license",
  "Koha::Schema::Result::ErmLicense",
  { license_id => "license_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-10-21 09:22:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rbU2G4zjKlEcOtuwVBSXaw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
