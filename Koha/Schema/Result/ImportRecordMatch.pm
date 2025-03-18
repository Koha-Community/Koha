use utf8;
package Koha::Schema::Result::ImportRecordMatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportRecordMatch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_record_matches>

=cut

__PACKAGE__->table("import_record_matches");

=head1 ACCESSORS

=head2 import_record_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the id given to the imported bib record (import_records.import_record_id)

=head2 candidate_match_id

  data_type: 'integer'
  is_nullable: 0

the biblio the imported record matches (biblio.biblionumber)

=head2 score

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

the match score

=head2 chosen

  data_type: 'tinyint'
  is_nullable: 1

whether this match has been allowed or denied

=cut

__PACKAGE__->add_columns(
  "import_record_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "candidate_match_id",
  { data_type => "integer", is_nullable => 0 },
  "score",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "chosen",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</import_record_id>

=item * L</candidate_match_id>

=back

=cut

__PACKAGE__->set_primary_key("import_record_id", "candidate_match_id");

=head1 RELATIONS

=head2 import_record

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportRecord>

=cut

__PACKAGE__->belongs_to(
  "import_record",
  "Koha::Schema::Result::ImportRecord",
  { import_record_id => "import_record_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-05-03 20:30:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a1GMA3K9ZgtPGdsCWmDMFw

__PACKAGE__->add_columns(
    '+chosen' => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Import::Record::Match';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Import::Record::Matches';
}

1;
